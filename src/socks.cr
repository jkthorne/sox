require "socket"

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

require "./connection_buffer.cr"
require "./connection_request.cr"
require "./connection_response.cr"

socks_socket = TCPSocket.new("127.0.0.1", 1080)

connection_request = ConnectionRequest.new
socks_socket.write(connection_request.buffer)

connection_response = ConnectionResponse.new
socks_socket.read(connection_response.buffer)
puts connection_response.auth_message

## CONNECT
connect_message = ConnectBuffer.new
connect_message.bind_addr = "93.184.216.34"

pp! connect_message
socks_socket.write(connect_message.buffer)

## RECIEVE
connect_reply = Bytes.new(4)
socks_socket.read(connect_reply)

puts "Server doesn't reply" if connect_reply.empty?
puts "SOCKS version #{connect_reply[0]} is not 5" if connect_reply[0] != 0o005

case connect_reply[1]
when 1
  puts "general SOCKS server failure"
when 2
  puts "connection not allowed by ruleset"
when 3
  puts "Network unreachable"
when 4
  puts "Host unreachable"
when 5
  puts "Connection refused"
when 6
  puts "TTL expired"
when 7
  puts "Command not supported"
when 8
  puts "Address type not supported"
end

puts "NOT IPv4" if connect_reply[3] != 0o001

pp! connect_reply

socks_socket << "GET / HTTP/1.1\nhost: www.example.com\n\n"
25.times do
  puts socks_socket.gets
end

socks_socket.close
