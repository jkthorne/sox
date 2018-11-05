require "./spec_helper"

describe Socks::ConnectionRequest do
  it "default buffer" do
    c_request = Socks::ConnectionRequest.new
    c_request.buffer.should eq Bytes[
      Socks::V5, Socks::COMMAND::CONNECT, Socks::RESERVED
    ]
  end

  it "initializes with version" do
    c_request = Socks::ConnectionRequest.new(version: Socks::V4)
    c_request.buffer.should eq Bytes[
      Socks::V4, Socks::COMMAND::CONNECT, Socks::RESERVED
    ]
  end

  it "initializes with version" do
    c_request = Socks::ConnectionRequest.new(command: Socks::COMMAND::BIND)
    c_request.buffer.should eq Bytes[
      Socks::V5, Socks::COMMAND::BIND, Socks::RESERVED
    ]
  end
end
