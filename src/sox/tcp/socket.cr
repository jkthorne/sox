class Sox::TCP::Socket < TCPSocket
  def initialize(*args)
    super(args)
    connect_host
    connect_remote(addr, port)
  end

  private def connect_host
    connection_request = ConnectionRequest.new
    write(connection_request.buffer)

    connection_response = ConnectionResponse.new
    read(connection_response.buffer)
    connection_response
  end

  private def connect_remote(addr : String, port : Int)
    request = Request.new(addr: addr, port: port)
    write(request.buffer)

    reply = Reply.new(buffer_size: request.size)
    read(reply.buffer)
    reply
  end
end
