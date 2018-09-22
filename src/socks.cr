require "socket"

class Socks
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

  def connect_host(socks_socket)
    connection_request = ConnectionRequest.new
    socks_socket.write(connection_request.buffer)

    connection_response = ConnectionResponse.new
    socks_socket.read(connection_response.buffer)
    puts "HOST STATUS: #{connection_response.server_message}"
  end

  def connect_remote(socks_socket)
    connect_message = Request.new
    connect_message.bind_addr = "93.184.216.34"
    socks_socket.write(connect_message.buffer)

    connect_reply = Reply.new
    socks_socket.read(connect_reply.buffer)
    puts "REMOTE STATUS: #{connect_reply.server_message}"
  end

  def main
    socks_socket = TCPSocket.new("127.0.0.1", 1080)

    connect_host(socks_socket)
    connect_remote(socks_socket)

    socks_socket << "GET / HTTP/1.1\nhost: www.example.com\n\n"
    25.times do
      puts socks_socket.gets
    end

    socks_socket.close
  end
end

require "./connection_request.cr"
require "./connection_response.cr"
require "./request.cr"
require "./reply.cr"

Socks.new.main
