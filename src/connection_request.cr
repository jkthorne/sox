class Socks::ConnectionRequest
  property buffer : Bytes

  def initialize(version : UInt8 = V5, command : UInt8 = COMMAND::CONNECT)
    @buffer = Bytes[version, command, RESERVED]
  end

  def version
    buffer[0]
  end

  def command
    buffer[1]
  end

  def inspect(io)
    io << "#<Socks::ConnectionRequest version=#{version} command=#{command}>"
  end
end
