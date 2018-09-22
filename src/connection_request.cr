class ConnectionRequest
  property buffer

  def initialize
    @buffer = Bytes.new(3)
  end

  def version
    @buffer[0]
  end

  def command=(command new_command : Symbol)
    if :connect
      @buffer[1] = COMMAND::CONNECT
    elsif :bind
      @buffer[1] = COMMAND::BIND
    elsif :udp
      @buffer[1] = COMMAND::UDP_ASSOCIATE
    end
    command
  end

  def command
    @buffer[1]
  end
end
