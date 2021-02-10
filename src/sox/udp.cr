require "../sox.cr"

module Sox
  def self.udp(*args)
    SoxUDP.new(*args)
  end

end

class SoxUDP < UDPSocket
  def initialize(*args, @host_addr : String, @host_port : Int32)
    super(*args)
  end
end
