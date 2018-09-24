class Socks::ConnectionRequest
  property buffer

  def initialize
    @buffer = Bytes.new(3)
    @buffer[0] = VERSION
    @buffer[1] = COMMAND::CONNECT
    @buffer[2] = RESERVED
  end

  def self.default_buffer
    new.buffer
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

  def inspect(io)
    io << "#<Socks::ConnectionRequest version=#{version} command=#{command}>"
  end
end
