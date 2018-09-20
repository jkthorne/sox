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

struct ConnectReply
  property buffer

  def initialize(@buffer : Bytes)
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
  end

  def bind_port
    buffer[-1]
  end

  def inspect(io)
    io << "v:" << version << " r:" << reply << " t:" << addr_type <<
          " a:" << bind_addr << " p:" << bind_port
  end
end

socks_socket = TCPSocket.new("127.0.0.1", 1080)

handshake = Bytes.new(3)
handshake[0] = VERSION ## Socks Version Number
handshake[1] = COMMAND::CONNECT
handshake[2] = RESERVED
socks_socket.write(handshake)
# socks_socket.write "\005\001\000".to_slice ## NO AUTHENTICATION

auth_reply = Bytes.new(2)
socks_socket.read(auth_reply)

pp! auth_reply

if auth_reply.empty?
  puts "Server doesn't reply authentication"
elsif auth_reply[0] != 0o004 && auth_reply[0] != 0o005
  puts "SOCKS version #{auth_reply[0]} not supported"
elsif auth_reply[1] != 0o000
  puts "SOCKS authentication method #{auth_reply[1]} neither requested nor supported"
end

## CONNECT
connect_message = Bytes.new(10)

connect_message[0] = VERSION
connect_message[1] = COMMAND::CONNECT
connect_message[2] = RESERVED
## ADDR 93.184.216.34
connect_message[3] = ADDR_TYPE::IPV4
connect_message[4] = 93_u8
connect_message[5] = 184_u8
connect_message[6] = 216_u8
connect_message[7] = 34_u8
## PORT
connect_message[8] = 0_u8
connect_message[9] = 80_u8

pp! connect_message
socks_socket.write(connect_message)

## RECIEVE
connect_reply = Bytes.new(4)
socks_socket.read(connect_reply)

puts "Server doesn't reply" if connect_reply.empty?
puts "SOCKS version #{connect_reply[0]} is not 5" if connect_reply[0] != 0o005

pp! ConnectReply.new(connect_reply)

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

socks_socket.close%                                                                                                                    (spark:crystal)$