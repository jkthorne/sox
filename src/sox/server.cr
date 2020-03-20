require "../sox.cr"
require "http/server"

module Sox
  def self.server(*args)
    Sox::Server.new(*args)
  end
end

class HTTP::Server
  def bind_socks(addr : String, port : Int32, host_addr : String, host_port : Int32)
    tcp_server = Sox.new(addr, port, host_addr, host_port, command: Sox::COMMAND::BIND)

    bind(tcp_server)

    tcp_server.local_address
  end
end
