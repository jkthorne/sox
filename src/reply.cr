class Sox::Reply
  property buffer : Bytes

  def initialize(buffer_size : Int = 10)
    @buffer = Bytes.new(buffer_size)
  end

  def version
    buffer[0]
  end

  def reply
    COMMAND.from_value?(buffer[1])
  end

  def addr_type
    ADDR_TYPE.from_value?(buffer[3])
  end

  def addr
    case addr_type
    when ADDR_TYPE::IPV4
      buffer[4, 4].join(".")
    when ADDR_TYPE::IPV6
      new_addr = [] of Int32
      buffer[4, 16].each_cons(9) { |slice|
        new_addr << slice.reduce(0) { |a, i|
          a + i
        }
      }
      Socket::IPAddress.new(new_addr.join(":"), port.to_i32).address
    when ADDR_TYPE::DOMAIN
      String.new(buffer[5, buffer[4]])
    end
  end

  def port
    port_buffer = buffer[buffer.size - 2, 2].to_slice
    IO::ByteFormat::NetworkEndian.decode(Int16, port_buffer)
  end

  def server_message
    return "Server doesn't reply" if buffer.empty?
    return "SOCKS version #{version} is not supported" if ![V4, V5].includes?(version)
    return "ADDR type not supported" if !ADDR_TYPE.values.includes?(addr_type)

    case buffer[2]
    when 0_u8
      "succeeded"
    when 1_u8
      "general SOCKS server failure"
    when 2_u8
      "connection not allowed by ruleset"
    when 3_u8
      "Network unreachable"
    when 4_u8
      "Host unreachable"
    when 5_u8
      "Connection refused"
    when 6_u8
      "TTL expired"
    when 7_u8
      "Command not supported"
    when 8_u8
      "Address type not supported"
    else
      "Unknown State"
    end
  end

  def size
    buffer.size
  end

  def inspect(io)
    io << "#<Sox::Reply version=#{version} reply=#{reply} "
    io << "addr_type=#{addr_type} addr=#{addr} port=#{port}>"
  end
end
