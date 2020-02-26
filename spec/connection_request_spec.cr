require "./spec_helper"

describe Sox::ConnectionRequest do
  it "default buffer" do
    c_request = Sox::ConnectionRequest.new
    c_request.buffer.should eq Bytes[
      Sox::V5, Sox::COMMAND::CONNECT, Sox::RESERVED,
    ]
  end

  it "initializes with version" do
    c_request = Sox::ConnectionRequest.new(version: Sox::V4)
    c_request.buffer.should eq Bytes[
      Sox::V4, Sox::COMMAND::CONNECT, Sox::RESERVED,
    ]
  end

  it "initializes with version" do
    c_request = Sox::ConnectionRequest.new(command: Sox::COMMAND::BIND)
    c_request.buffer.should eq Bytes[
      Sox::V5, Sox::COMMAND::BIND, Sox::RESERVED,
    ]
  end
end
