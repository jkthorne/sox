class Socks::Reply
  property buffer

  def initialize(buffer = Bytes.new(10))
    @buffer = buffer
  end

  def version
    buffer[0]
  end

  def reply
    buffer[1]
  end

  def reserved
    buffer[2]
  end

  def addr_type
    buffer[3]
  end

  def bind_addr
    buffer[4, 4]
  end

  def bind_port
    buffer[buffer.size - 2, 2]
  end

  def server_message
    message = "Unknown State"

    message = "Server doesn't reply" if buffer.empty?
    message = "SOCKS version #{buffer[0]} is not 5" if buffer[0] != VERSION
    message = "NOT IPv4" if buffer[3] != 0o001

    case buffer[1]
    when 0_u8
      message = "succeeded"
    when 1_u8
      message = "general SOCKS server failure"
    when 2_u8
      message = "connection not allowed by ruleset"
    when 3_u8
      message = "Network unreachable"
    when 4_u8
      message = "Host unreachable"
    when 5_u8
      message = "Connection refused"
    when 6_u8
      message = "TTL expired"
    when 7_u8
      message = "Command not supported"
    when 8_u8
      message = "Address type not supported"
    end

    message
  end

  def inspect(io)
    io << "#<Socks::Reply version=#{version} reply=#{reply} "
    io << "addr_type=#{addr_type} bind_addr=#{bind_addr} bind_port=#{bind_port}>"
  end
end
