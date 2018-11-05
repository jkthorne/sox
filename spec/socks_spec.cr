require "./spec_helper"

private def ping_server
  HTTP::Server.new do |context|
    context.response.content_type = "text/plain"
    if context.request.path == "/ping"
      context.response.puts "pong"
    end
  end
end

describe Socks do
  it "smokes test" do
    begin
      server = ping_server
      address = server.bind_unused_port "127.0.0.1"
      spawn { server.try &.listen }

      socket = Socks.new(host_addr: "127.0.0.1", host_port: SSH_PORT, addr: "127.0.0.1", port: address.port)

      headers = HTTP::Headers{"Host" => "127.0.0.1:#{address.port}"}
      request = HTTP::Request.new("GET", "/ping", headers)

      request.to_io(socket)
      socket.flush
      response = HTTP::Client::Response.from_io?(socket)

      response.not_nil!.body.chomp.should eq "pong"
    ensure
      server.try &.close
    end
  end

  it "tor" do
    socket = Socks.new(host_addr: "127.0.0.1", host_port: 9050, addr: "93.184.216.34", port: 80)

    headers = HTTP::Headers{"Host" => "www.example.com"}
    request = HTTP::Request.new("GET", "/", headers)

    request.to_io(socket)
    socket.flush
    response = HTTP::Client::Response.from_io?(socket)

    response.not_nil!.success?.should be_true
  end

  it "udp" do
    begin
      udp_port = rand(8000..10000)
      server = UDPSocket.new
      address = server.bind "127.0.0.1", udp_port

      socket = Socks.new(host_addr: "127.0.0.1", host_port: SSH_PORT, addr: "127.0.0.1", port: udp_port,
                          command: Socks::COMMAND::UDP_ASSOCIATE)

      socket.connect "127.0.0.1", udp_port
      socket.send "yolo"

      message, client_addr = server.receive

      message.should eq "yolo"
    ensure
      socket.try &.close
      server.try &.close
    end
  end
end
