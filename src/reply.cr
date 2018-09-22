class Socks::Reply
  property buffer

  def initialize
    @buffer = Bytes.new(4)
  end

  def server_message
    message = "Server Connected"

    message = "Server doesn't reply" if buffer.empty?
    message = "SOCKS version #{buffer[0]} is not 5" if buffer[0] != VERSION
    message = "NOT IPv4" if buffer[3] != 0o001

    case buffer[1]
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
end
