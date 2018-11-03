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
    elsif ![V4, V5].includes? version
      "SOCKS version #{version} not supported"
    elsif ![AUTH::NO_AUTHENTICATION, AUTH::GSSAPI, AUTH::USERNAME_PASSWORD,
           AUTH::IANA, AUTH::RESERVED, AUTH::NO_ACCEPTABLE_METHODS].includes? method
      "SOCKS authentication method #{method} neither requested nor supported"
    else
      "Server connected"
    end
  end

  def inspect(io)
    io << "#<Socks::Request version=#{version} method=#{method}>"
  end
end
