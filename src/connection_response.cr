class ConnectionResponse
  property buffer

  def initialize
    @buffer = Bytes.new(2)
  end

  def connected?
    buffer[0] == VERSION && buffer[1] == 0_u8
  end

  def unconnected?
    !connected?
  end

  def auth_message
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
end
