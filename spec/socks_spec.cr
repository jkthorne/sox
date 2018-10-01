require "./spec_helper"

describe Socks do
  it "smokes test" do
    server_port = 5678
    server = HTTP::Server.new do |context|
      STDOUT.puts "SERVER"
      context.response.content_type = "text/plain"
      if context.request.path == "/ping"
        context.response.print "pong"
      end
    end

    tcp_server = TCPServer.new("127.0.0.1", server_port)
    server.bind tcp_server
    address = tcp_server.local_address

    spawn { server.listen }
    Fiber.yield

    HTTP::Client.get("http://#{address}/ping").body.should eq "pong"
    Socks.new("127.0.0.1", 1080).main("localhost", "/ping")
  end
end
