require "../socks.cr"
require "http/server"

class HTTP::Server
  def bind_socks(addr : String, port : Int32, host_addr : String, host_port : Int32)
    tcp_server = Socks.new(addr, port, host_addr, host_port, command: Socks::COMMAND::BIND)

    bind(tcp_server)

    tcp_server.local_address
  end
end
