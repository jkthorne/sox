require "../spec_helper"

describe Sox::Client do
  it "connect" do
    begin
      server = HTTP::Server.new do |context|
        context.response.content_type = "text/plain"
        if context.request.path == "/ping"
          context.response << "pong"
        end
      end
      address = server.bind_unused_port "127.0.0.1"
      spawn { server.try &.listen }

      client = Sox::Client.new("127.0.0.1", address.port, host_addr: "127.0.0.1", host_port: SSH_PORT)
      response = client.get("/ping")
      response.try &.body.should eq "pong"
    ensure
      server.try &.close
    end
  end
end
