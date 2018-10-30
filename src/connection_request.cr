class Socks::ConnectionRequest
  property buffer : Bytes

  def initialize
    @buffer = Bytes[VERSION, COMMAND::CONNECT, RESERVED]
  end

  def version=(version : Int)
    buffer[0] = version.to_u8
    version
  end

  def version
    buffer[0]
  end

  def command=(command : Symbol)
    case command
    when :connect
      buffer[1] = COMMAND::CONNECT
    when :bind
      buffer[1] = COMMAND::BIND
    when :udp
      buffer[1] = COMMAND::UDP_ASSOCIATE
    end
    command
  end

  def command
    buffer[1]
  end

  def inspect(io)
    io << "#<Socks::ConnectionRequest version=#{version} command=#{command}>"
  end
end
