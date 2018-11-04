class Socks::Request
  DEFAULT_BYTE = RESERVED ## dont need to allocate more 0_u8
  IPV4_BUFFER = Bytes[
    V5, COMMAND::CONNECT, RESERVED, ADDR_TYPE::IPV4, DEFAULT_BYTE,
    DEFAULT_BYTE, DEFAULT_BYTE, DEFAULT_BYTE, DEFAULT_BYTE, DEFAULT_BYTE
  ]
  IPV6_BUFFER = Bytes[
    V5, COMMAND::CONNECT, RESERVED, ADDR_TYPE::IPV6, DEFAULT_BYTE,
    DEFAULT_BYTE, DEFAULT_BYTE, DEFAULT_BYTE, DEFAULT_BYTE, DEFAULT_BYTE,
    DEFAULT_BYTE, DEFAULT_BYTE, DEFAULT_BYTE, DEFAULT_BYTE, DEFAULT_BYTE,
    DEFAULT_BYTE, DEFAULT_BYTE, DEFAULT_BYTE, DEFAULT_BYTE, DEFAULT_BYTE,
    DEFAULT_BYTE, DEFAULT_BYTE
  ]
  DOMAIN_BUFFER = Bytes[V5, COMMAND::CONNECT, RESERVED, ADDR_TYPE::DOMAIN]

  property buffer : Bytes

  def initialize(addr : String , port : Int = 80)
    @buffer = IPV4_BUFFER.clone
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
    case addr_type
    when ADDR_TYPE::IPV4
      new_addr.split(".").each_with_index { |b, i|
        buffer[4 + i] = b.to_u8
      }
    when ADDR_TYPE::IPV6   #TODO
    when ADDR_TYPE::DOMAIN #TODO
    end
    addr
  end

  def addr
    case addr_type
    when ADDR_TYPE::IPV4
      buffer[4, buffer.size - 6].join(".")
    when ADDR_TYPE::IPV6   #TODO
    when ADDR_TYPE::DOMAIN #TODO
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
end
