require "./spec_helper"

describe Socks::Request do
  it "default buffer" do
    expected_buffer = Socks::Request::IPV4_BUFFER

    actual_request = Socks::Request.new(addr: "0.0.0.0", port: 0)
    
    actual_request.buffer.should eq expected_buffer
  end

  it "initializes with values" do
    expected_addr = "127.0.0.1"
    expected_port = 80

    actual_request = Socks::Request.new(addr: expected_addr, port: expected_port)
    
    actual_request.addr.should eq expected_addr
    actual_request.port.should eq expected_port 
  end

  it "sets versions" do
    expected_version = Socks::V5
    actual_request = Socks::Request.new("127.0.0.1")
    
    actual_request.version.should eq expected_version
  end

  it "sets reply" do
    expected_reply = Socks::COMMAND::BIND

    actual_request = Socks::Request.new("127.0.0.1")
    
    actual_request.reply = expected_reply
    actual_request.reply.should eq expected_reply

    actual_request.reply = :connect
    actual_request.reply.should eq Socks::COMMAND::CONNECT
  end

  it "sets addr_type" do
    expected_addr_type = Socks::ADDR_TYPE::IPV6

    actual_request = Socks::Request.new("127.0.0.1")

    actual_request.addr_type = expected_addr_type
    actual_request.addr_type.should eq expected_addr_type

    actual_request.addr_type = :domain
    actual_request.addr_type.should eq Socks::ADDR_TYPE::DOMAIN
  end

  describe "addr" do
    it "sets ipv4 addr" do
      expected_addr = "225.225.225.225"
      actual_request = Socks::Request.new("::1")

      actual_request.addr = expected_addr
      actual_request.addr.should eq expected_addr
    end

    it "sets ipv6 addr" do
      expected_addr = "0:0:0:0:0:0:0:1"
      expected_addr_alt = "::1"
      actual_request = Socks::Request.new("127.0.0.1")

      actual_request.addr = expected_addr
      actual_request.addr.should eq expected_addr

      actual_request.addr = expected_addr_alt
      actual_request.addr.should eq expected_addr
    end
  end

  it "sets port" do
    expected_port = 8888
    actual_request = Socks::Request.new("127.0.0.1")

    actual_request.port = expected_port
    actual_request.port.should eq expected_port
  end
end
