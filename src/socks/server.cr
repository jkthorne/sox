require "../socks.cr"
require "http/server"

class Socks
  def self.server(*args)
    Socks::Server.new(*args)
  end
end

class HTTP::Server
  def bind_socks(addr : String, port : Int32, host_addr : String, host_port : Int32)
    tcp_server = Socks.new(addr, port, host_addr, host_port, command: Socks::COMMAND::BIND) # # server Socks

    bind(tcp_server)

    tcp_server.local_address
  end
end
