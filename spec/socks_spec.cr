require "./spec_helper"

describe Socks do
  it "smokes test" do
    server = HTTP::Server.new do |context|
      context.response.content_type = "text/plain"
      if context.request.path == "/ping"
        context.response.print "pong"
      end
    end

    begin
      address = server.bind_unused_port "127.0.0.1"
      spawn { server.listen }

      socket = Socks.new("127.0.0.1", 1080)
      socket.connect_host
      socket.connect_remote("127.0.0.1", address.port)

      headers = HTTP::Headers{"Host" => "127.0.0.1:#{address.port}"}
      request = HTTP::Request.new("GET", "/ping", headers)

      request.to_io(socket)
      socket.flush
      response = HTTP::Client::Response.from_io?(socket)

      response.not_nil!.body.chomp.should eq "pong"
    ensure
      server.close
    end
  end

  it "tor" do
    socket = Socks.new("127.0.0.1", 9050)
    socket.connect_host
    socket.connect_remote("93.184.216.34", 80)

    headers = HTTP::Headers{"Host" => "www.example.com"}
    request = HTTP::Request.new("GET", "/", headers)

    request.to_io(socket)
    socket.flush
    response = HTTP::Client::Response.from_io?(socket)

    response.not_nil!.success?.should be_true
  end
end
