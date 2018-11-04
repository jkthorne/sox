class Socks::Request
  IPV4_BUFFER = Bytes[
    V5, COMMAND::CONNECT, RESERVED, ADDR_TYPE::IPV4, BLANK_BYTE,
    BLANK_BYTE, BLANK_BYTE, BLANK_BYTE, BLANK_BYTE, BLANK_BYTE
  ]
  IPV6_BUFFER = Bytes[
    V5, COMMAND::CONNECT, RESERVED, ADDR_TYPE::IPV6, BLANK_BYTE,
    BLANK_BYTE, BLANK_BYTE, BLANK_BYTE, BLANK_BYTE, BLANK_BYTE,
    BLANK_BYTE, BLANK_BYTE, BLANK_BYTE, BLANK_BYTE, BLANK_BYTE,
    BLANK_BYTE, BLANK_BYTE, BLANK_BYTE, BLANK_BYTE, BLANK_BYTE,
    BLANK_BYTE, BLANK_BYTE
  ]
  DEFAULT_BUFFER = Bytes[V5, COMMAND::CONNECT, RESERVED, ADDR_TYPE::DOMAIN, BLANK_BYTE, BLANK_BYTE]

  property buffer : Bytes

  def initialize(addr : String , port : Int = 80)
    case IPAddress.new(addr, port).family
    when Family::INET
      @buffer = IPV4_BUFFER.clone
    when Family::INET6
      @buffer = IPV6_BUFFER.clone
    else
      @buffer = DEFAULT_BUFFER.clone
    end
    self.addr = addr
    self.port = port
  end

  def version=(version : Int)
    buffer[0] = version.to_u8
    version
  end

  def version
    buffer[0]
  end

  def reply=(command : Symbol)
    case command
    when :connect
      buffer[1] = COMMAND::CONNECT
    when :bind
      buffer[1] = COMMAND::BIND
    when :udp
      buffer[1] = COMMAND::UDP_ASSOCIATE
    end
    reply
  end

  def reply=(command : UInt8)
    buffer[1] = command
  end

  def reply
    buffer[1]
  end

  def addr_type=(addr_type : UInt8)
    buffer[3] = addr_type
    addr_type
  end

  def addr_type=(addr_type new_addr_type : Symbol = :ipv4)
    case new_addr_type
    when :ipv4
      buffer[3] = ADDR_TYPE::IPV4
    when :ipv6
      buffer[3] = ADDR_TYPE::IPV6
    when :domain
      buffer[3] = ADDR_TYPE::DOMAIN
    end
    addr_type
  end

  def addr_type
    buffer[3]
  end

  def addr=(addr new_addr : String)
    if new_addr.scan(/[a-zA-Z]/).size > 0
      new_buffer = Bytes.new(new_addr.size + 6)

      buffer[0, 2].copy_to new_buffer[0, 2]                                 ## copy meta data
      new_buffer[3] = ADDR_TYPE::DOMAIN                                     ## set addr type
      new_addr.to_slice.copy_to(new_buffer[4, new_addr.to_slice.size])      ## copy domain
      buffer[buffer.size - 2, 2].copy_to new_buffer[new_buffer.size - 2, 2] ## copy ports

      @buffer = new_buffer
      return addr
    end

    ip_address = Socket::IPAddress.new(new_addr, port.to_i32)

    case ip_address.family
    when Family::INET
      alter_buffer(ADDR_TYPE::IPV4)
      ip_address.address.split(".").each_with_index { |b, i|
        buffer[4 + i] = b.to_u8
      }
    when Family::INET6
      alter_buffer(ADDR_TYPE::IPV6)
      {% if flag?(:darwin) || flag?(:openbsd) || flag?(:freebsd) %}
        ip_address.@addr6.not_nil!.__u6_addr.__u6_addr8.to_slice.copy_to buffer[4, 16]
      {% elsif flag?(:linux) && flag?(:musl) %}
        ip_address.@addr6.not_nil!.__in6_union.__s6_addr.to_slice.copy_to buffer[4, 16]
      {% elsif flag?(:linux) %}
        ip_address.@addr6.not_nil!.__in6_u.__u6_addr8.to_slice.copy_to buffer[4, 16]
      {% else %}
        {% raise "Unsupported platform" %}
      {% end %}
    end

    addr
  end

  def addr
    case addr_type
    when ADDR_TYPE::IPV4
      Socket::IPAddress.new(buffer[4, 4].join("."), port.to_i32).address
    when ADDR_TYPE::IPV6
      new_addr = [] of Int32
      buffer[4, 16].each_cons(9) { |slice|
        new_addr << slice.reduce(0) { |a,i|
          a + i
        }
      }
      Socket::IPAddress.new(new_addr.join(":"), port.to_i32).address
    when ADDR_TYPE::DOMAIN
      String.new(buffer[4, buffer.size - 6])
    end
  end

  def port=(port_number : Int)
    port_buffer = buffer[buffer.size - 2, 2].to_slice
    IO::ByteFormat::NetworkEndian.encode(port_number.to_u16, port_buffer)
    port
  end

  def port
    port_buffer = buffer[buffer.size - 2, 2].to_slice
    IO::ByteFormat::NetworkEndian.decode(Int16, port_buffer)
  end

  def size
    buffer.size
  end

  def inspect(io)
    io << "#<Socks::Request version=#{version} reply=#{reply} "
    io << "addr_type=#{addr_type} addr=#{addr} port=#{port}>"
  end

  private def alter_buffer(new_addr_type : UInt8)
    case new_addr_type
    when ADDR_TYPE::IPV4
      new_buffer = IPV4_BUFFER.clone
      buffer[0, 2].copy_to new_buffer[0, 2]
      buffer[buffer.size - 2, 2].copy_to new_buffer[new_buffer.size - 2, 2]
      @buffer = new_buffer
    when ADDR_TYPE::IPV6
      new_buffer = IPV6_BUFFER.clone
      buffer[0, 2].copy_to new_buffer[0, 2]
      buffer[buffer.size - 2, 2].copy_to new_buffer[new_buffer.size - 2, 2]
      @buffer = new_buffer
    end
  end
end
