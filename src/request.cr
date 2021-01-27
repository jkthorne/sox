class Sox::Request
  property buffer : Bytes

  def initialize(addr : String, port : Int = 80, version : UInt8 = V5, command : COMMAND = COMMAND::CONNECT)
    if addr.scan(/[a-zA-Z]/).size > 0
      @buffer = Bytes.new(addr.size + 7)
      @buffer[3] = ADDR_TYPE::DOMAIN.value
      @buffer[4] = addr.to_slice.size.to_u8
      addr.to_slice.copy_to(@buffer[5, addr.to_slice.size])
    else
      ip_address = Socket::IPAddress.new(addr, port)
      case ip_address.family
      when Socket::Family::INET
        @buffer = Bytes.new(10)
        @buffer[3] = ADDR_TYPE::IPV4.value
        ip_address.address.split(".").each_with_index { |b, i|
          @buffer[4 + i] = b.to_u8
        }
      when Socket::Family::INET6
        @buffer = Bytes.new(22)
        @buffer[3] = ADDR_TYPE::IPV6.value
        {% if flag?(:darwin) || flag?(:openbsd) || flag?(:freebsd) %}
          ip_address.@addr6.not_nil!.__u6_addr.__u6_addr8.to_slice.copy_to @buffer[4, 16]
        {% elsif flag?(:linux) && flag?(:musl) %}
          ip_address.@addr6.not_nil!.__in6_union.__s6_addr.to_slice.copy_to @buffer[4, 16]
        {% elsif flag?(:linux) %}
          ip_address.@addr6.not_nil!.__in6_u.__u6_addr8.to_slice.copy_to @buffer[4, 16]
        {% else %}
          {% raise "Unsupported platform" %}
        {% end %}
      else
        raise "invalid addr type for Sox::Request"
      end
    end

    # Set Socks version
    @buffer[0] = version

    # Set Socks command
    @buffer[1] = command.value

    # Set port
    IO::ByteFormat::NetworkEndian.encode(
      port.to_u16, @buffer.[@buffer.size - 2, 2].to_slice
    )
  end

  def version
    buffer[0]
  end

  def reply
    COMMAND.from_value?(buffer[1])
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
    ADDR_TYPE.from_value?(buffer[3])
  end

  def addr
    case addr_type
    when ADDR_TYPE::IPV4
      Socket::IPAddress.new(buffer[4, 4].join("."), port.to_i32).address
    when ADDR_TYPE::IPV6
      new_addr = [] of Int32
      buffer[4, 16].each_cons(9) { |slice|
        new_addr << slice.reduce(0) { |a, i|
          a + i
        }
      }
      Socket::IPAddress.new(new_addr.join(":"), port.to_i32).address
    when ADDR_TYPE::DOMAIN
      String.new(buffer[5, buffer[4]])
    end
  end

  def port
    port_buffer = buffer[buffer.size - 2, 2].to_slice
    IO::ByteFormat::NetworkEndian.decode(Int16, port_buffer)
  end

  def size
    buffer.size
  end

  def inspect(io)
    io << "#<Sox::Request version=#{version} reply=#{reply} "
    io << "addr_type=#{addr_type} addr=#{addr} port=#{port}>"
  end
end
