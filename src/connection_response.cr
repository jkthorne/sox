class Sox::ConnectionResponse
  property buffer

  def initialize
    @buffer = Bytes.new(2, MARK_BYTE)
  end

  def version
    buffer[0]
  end

  def method
    Sox::AUTH.from_value?(buffer[1])
  end

  def connected?
    version != MARK_BYTE && [V4, V5].includes?(version) && method == AUTH::NO_AUTHENTICATION
  end

  def unconnected?
    !connected?
  end

  def server_message
    if buffer.empty?
      "Server doesn't reply authentication"
    elsif ![V4, V5].includes? version
      "SOCKS version #{version} not supported"
    elsif !AUTH.values.includes? method
      "SOCKS authentication method #{buffer[1]} neither requested nor supported"
    else
      "Server connected"
    end
  end

  def inspect(io)
    io << "#<Sox::Request version=#{version} method=#{method}>"
  end
end
