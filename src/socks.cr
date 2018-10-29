require "socket"

class Socks < TCPSocket
  VERSION = 5_u8
  RESERVED = 0_u8

  module AUTH
    NO_AUTHENTICATION     = 0_u8
    GSSAPI                = 1_u8
    USERNAME_PASSWORD     = 2_u8
    IANA                  = 3_u8 ## X'03' to X'7F' IANA ASSIGNED
    RESERVED              = 80_u8 ## o  X'80' to X'FE' RESERVED FOR PRIVATE METHODS
    NO_ACCEPTABLE_METHODS = 0_255
  end

  module COMMAND
    CONNECT       = 1_u8
    BIND          = 2_u8
    UDP_ASSOCIATE = 3_u8
  end

  module ADDR_TYPE
    IPV4       = 1_u8
    DOMAINNAME = 3_u8
    IPV6       = 4_u8
  end

  def connect_host
    connection_request = ConnectionRequest.new
    write(connection_request.buffer)

    connection_response = ConnectionResponse.new
    read(connection_response.buffer)
    self
  end

  def connect_remote(addr : String, port : Int)
    request = Request.new(addr: addr, port: port)

    write(request.buffer)

    reply = Reply.new
    read(reply.buffer)
    self
  end

  def connect(addr : String, port : Int, host_addr : String = "127.0.0.1", host_port : Int = 1080)
    connect_host
    connect_remote(addr, port)
  end
end

require "./connection_request.cr"
require "./connection_response.cr"
require "./request.cr"
require "./reply.cr"
