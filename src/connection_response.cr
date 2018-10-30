class Socks::ConnectionResponse
  MARK_BYTE = 255_u8

  property buffer

  def initialize
    @buffer = Bytes.new(2, MARK_BYTE)
  end

  def version
    buffer[0]
  end

  def method
    buffer[1]
  end

  def connected?
    version != MARK_BYTE && version == VERSION && method == AUTH::NO_AUTHENTICATION
  end

  def unconnected?
    !connected?
  end

  def server_message
    if buffer.empty?
      "Server doesn't reply authentication"
    elsif buffer[0] != 0o004 && buffer[0] != 0o005
      "SOCKS version #{buffer[0]} not supported"
    elsif buffer[1] != 0o000
      "SOCKS authentication method #{buffer[1]} neither requested nor supported"
    else
      "Server connected"
    end
  end

  def inspect(io)
    io << "#<Socks::Request version=#{buffer[0]} method=#{buffer[1]}>"
  end
end
