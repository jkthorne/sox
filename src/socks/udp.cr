require "../socks.cr"

class Socks::UDP < UDPSocket
  def initialize(*args, @host_addr : String, @host_port : Int32)
    super(*args)
  end
end
