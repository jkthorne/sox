class Socks::Request
  property buffer

  def initialize(addr : String , port : Int)
    @buffer = Bytes.new(10)

    buffer[0] = VERSION
    buffer[1] = COMMAND::CONNECT
    buffer[3] = 1_u8
    self.bind_addr = addr
    self.bind_port = port
  end

  def version
    buffer[0]
  end

  def reply=(command)
    case command
    when :connect
      buffer[1] = 1_u8
    when :bind
      buffer[1] = 2_u8
    when :udp
      buffer[1] = 3_u8
    end
    buffer[1]
  end

  def reply
    buffer[1]
  end

  def reserved
    buffer[2]
  end

  def addr_type=(addr_type = :ipv4)
    case addr_type
    when :ipv4
      buffer[3] = ADDR_TYPE::IPV4
    end
    buffer[3]
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

  def bind_port=(port_number)
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
