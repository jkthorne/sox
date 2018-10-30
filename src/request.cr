class Socks::Request
  property buffer

  def initialize(addr : String , port : Int)
    @buffer = Bytes.new(10)

    @buffer[0] = VERSION
    @buffer[1] = COMMAND::CONNECT
    @buffer[3] = 1_u8
    self.bind_addr = addr
    self.bind_port = port
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

  def reply
    buffer[1]
  end

  def reserved
    buffer[2]
  end

  def addr_type=(addr_type : Symbol = :ipv4)
    case addr_type
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

  def bind_addr=(address : String)
    if addr_type == ADDR_TYPE::IPV4
      address.split(".").each_with_index do |b, i|
        buffer[4 + i] = b.to_u8
      end
    end
    bind_addr
  end

  def bind_addr
    buffer[4, 4]
  end

  def bind_port=(port_number : Int)
    IO::ByteFormat::NetworkEndian.encode(port_number.to_u16, buffer[buffer.size - 2, 2].to_slice)
    bind_port
  end

  def bind_port
    buffer[buffer.size - 2, 2]
  end

  def inspect(io)
    io << "#<Socks::Request version=#{version} reply=#{reply} "
    io << "addr_type=#{addr_type} bind_addr=#{bind_addr} bind_port=#{bind_port}>"
  end
end
