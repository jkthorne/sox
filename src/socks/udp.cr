require "../socks.cr"

class Socks
  def self.udp(*args)
    Socks::UDP.new(*args)
  end
end

class Socks::UDP < UDPSocket
  def initialize(*args, @host_addr : String, @host_port : Int32)
    super(*args)
  end
end
