require "./spec_helper"

describe Socks do
  it "smokes test" do
    begin
      address = Factory.server.bind_unused_port "127.0.0.1"
      spawn { Factory.server.listen }

      socket = Socks.new(host_addr: "127.0.0.1", host_port: SSH_PORT, addr: "127.0.0.1", port: address.port)

      headers = HTTP::Headers{"Host" => "127.0.0.1:#{address.port}"}
      request = HTTP::Request.new("GET", "/ping", headers)

      request.to_io(socket)
      socket.flush
      response = HTTP::Client::Response.from_io?(socket)

      response.not_nil!.body.chomp.should eq "pong"
    ensure
      Factory.server.close
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
end
