require "../spec_helper"

describe Sox::UDP do
  it "associate" do
    begin
      udp_port = rand(8000..10000)
      server = UDPSocket.new
      server.bind "localhost", udp_port

      client = Sox::UDP.new(host_addr: "127.0.0.1", host_port: SSH_PORT)
      client.connect("localhost", udp_port)

      client.send("yolo")
      message, client_addr = server.receive

      message.should eq "yolo"
    ensure
      client.try &.close
      server.try &.close
    end
  end
end
