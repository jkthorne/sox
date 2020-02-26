require "../sox.cr"

class Sox
  def self.udp(*args)
    Sox::UDP.new(*args)
  end
end

class Sox::UDP < UDPSocket
  def initialize(*args, @host_addr : String, @host_port : Int32)
    super(*args)
  end
end
