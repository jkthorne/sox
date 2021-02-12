require "../../connection_request.cr"
require "../../connection_response.cr"
require "../../request.cr"
require "../../reply.cr"

class Sox::TCP::Socket < TCPSocket
  def initialize(*args, host_addr : String, host_port : Int)
    super(*args)
    connect_host
    connect_remote(host: host_addr, port: host_port)
  end

  private def connect_host
    connection_request = Sox::ConnectionRequest.new
    write(connection_request.buffer)

    connection_response = Sox::ConnectionResponse.new
    read(connection_response.buffer)
    connection_response
  end

  private def connect_remote(host : String, port : Int)
    request = Sox::Request.new(addr: host, port: port)
    write(request.buffer)

    reply = Sox::Reply.new(buffer_size: request.size)
    read(reply.buffer)
    reply
  end
end
