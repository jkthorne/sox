require "./spec_helper"

describe Socks::ConnectionRequest do
  it "default buffer" do
    c_request = Socks::ConnectionRequest.new
    c_request.buffer.should eq Bytes[
      Socks::VERSION, Socks::COMMAND::CONNECT, Socks::RESERVED
    ]
  end

  it "initializes with values" do
    v_request = Socks::ConnectionRequest.new(version: 4_u8)
    v_request.buffer.should eq Bytes[
      Socks::V4, Socks::COMMAND::CONNECT, Socks::RESERVED
    ]

    c_request = Socks::ConnectionRequest.new(command: :bind)
    c_request.buffer.should eq Bytes[
      Socks::V5, Socks::COMMAND::BIND, Socks::RESERVED
    ]
  end

  it "sets versions" do
    c_request = Socks::ConnectionRequest.new
    c_request.version = 100_u8
    c_request.version.should eq 100_u8
    
    c_request.version = 200
    c_request.version.should eq 200_u8
  end

  it "sets command" do
    c_request = Socks::ConnectionRequest.new
    c_request.command = :udp
    c_request.command.should eq Socks::COMMAND::UDP_ASSOCIATE
    
    c_request.command = Socks::COMMAND::BIND
    c_request.command.should eq Socks::COMMAND::BIND
  end
end
