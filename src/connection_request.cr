class Socks::ConnectionRequest
  property buffer : Bytes

  def initialize(version new_version : Int? = nil, command new_command : Symbol? = nil)
    @buffer = Bytes[VERSION, COMMAND::CONNECT, RESERVED]
    self.version = new_version if new_version
    self.command = new_command if new_command
  end

  def version=(version : (Int | UInt8))
    buffer[0] = version.to_u8
    version
  end

  def version
    buffer[0]
  end

  def command=(command new_command : UInt8)
    buffer[1] = new_command
    command
  end

  def command=(command new_command : Symbol)
    case new_command
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
