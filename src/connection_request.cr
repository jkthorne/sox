class Sox::ConnectionRequest
  property buffer : Bytes

  def initialize(version : UInt8 = V5, command : COMMAND = COMMAND::CONNECT)
    @buffer = Bytes[version, command.value, RESERVED]
  end

  def version
    buffer[0]
  end

  def command
    COMMAND.from_value?(buffer[1])
  end

  def inspect(io)
    io << "#<Sox::ConnectionRequest version=#{version} command=#{command}>"
  end
end
