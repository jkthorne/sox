require "../spec_helper"

describe Socks::Server do
  it "bind" do
    begin
      bind_port = rand(8000..10000)
      server = HTTP::Server.new{|ctx| ctx.response << "yolo"}
      server.bind_socks("127.0.0.1", bind_port, "127.0.0.1", SSH_PORT)

      spawn { server.try &.listen }

      client = TCPSocket.new("127.0.0.1", SSH_PORT)
      client << "GET / HTTP 1.1\n\n"
      client.gets.should eq "yolo"
    ensure
      client.try &.close
      server.try &.close
    end
  end
end
