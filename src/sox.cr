require "socket"

require "./sox/tcp/socket"
require "./sox/tcp/server"
require "./sox/udp/socket"

module Sox
  V4         = 4_u8
  V5         = 5_u8
  BLANK_BYTE = 0_u8
  RESERVED   = BLANK_BYTE # # dont need to allocate more 0_u8
  MARK_BYTE  = 255_u8

  enum AUTH : UInt8
    NO_AUTHENTICATION     =   0_u8
    GSSAPI                =   1_u8
    USERNAME_PASSWORD     =   2_u8
    IANA                  =   3_u8 # # X'03' to X'7F' IANA ASSIGNED
    RESERVED              =  80_u8 # # o  X'80' to X'FE' RESERVED FOR PRIVATE METHODS
    NO_ACCEPTABLE_METHODS = 255_u8
  end

  enum COMMAND : UInt8
    CONNECT       = 1_u8
    BIND          = 2_u8
    UDP_ASSOCIATE = 3_u8
  end

  enum ADDR_TYPE : UInt8
    IPV4   = 1_u8
    IPV6   = 4_u8
    DOMAIN = 3_u8
  end

  def self.new(host : String,
               port : Int = 80,
               proxy_host : String = "127.0.0.1",
               proxy_port : Int = 1080,
               command : COMMAND = COMMAND::CONNECT,
               reuse_port : Bool = false)
    case command
    when COMMAND::CONNECT
      Sox::TCP::Socket.new(
        proxy_host,
        proxy_port,
        nil, # dns_timeout
        nil, # connect_timeout
        host_addr: host,
        host_port: port,
      )
    when COMMAND::UDP_ASSOCIATE
      socket = Sox::UDP::Socket.new
      socket.connect proxy_host, proxy_port
      socket
    when COMMAND::BIND
      Sox::TCP::Server.new(host: host, port: port)
    else
      raise "invalid command type"
    end
  end

  def receive(max_message_size = 512) : {String, IPAddress}
    address = nil
    message = String.new(max_message_size) do |buffer|
      bytes_read, sockaddr, addrlen = recvfrom(Slice.new(buffer, max_message_size))
      address = IPAddress.from(sockaddr, addrlen)
      {bytes_read, 0}
    end
    {message, address.not_nil!}
  end

  def receive(message : Bytes) : {Int32, IPAddress}
    bytes_read, sockaddr, addrlen = recvfrom(message)
    {bytes_read, IPAddress.from(sockaddr, addrlen)}
  end

  def tcp?
    @command == COMMAND::CONNECT || @command == COMMAND::BIND
  end

  def udp?
    @command == UDP_ASSOCIATE
  end
end
