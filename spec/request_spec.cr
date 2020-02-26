require "./spec_helper"

describe Sox::Request do
  it "default buffer" do
    expected_buffer = Bytes[
      Sox::V5, Sox::COMMAND::CONNECT, 0_u8, Sox::ADDR_TYPE::IPV4,
      0_u8, 0_u8, 0_u8, 0_u8, 0_u8, 0_u8,
    ]

    actual_request = Sox::Request.new(addr: "0.0.0.0", port: 0)

    actual_request.buffer.should eq expected_buffer
  end

  describe "initializes" do
    it "sets port" do
      expected_addr = "127.0.0.1"
      expected_port = 8888

      actual_request = Sox::Request.new(addr: expected_addr, port: expected_port)

      actual_request.addr.should eq expected_addr
      actual_request.port.should eq expected_port
    end

    it "sets versions" do
      expected_version = Sox::V4
      actual_request = Sox::Request.new("127.0.0.1", version: expected_version)

      actual_request.version.should eq expected_version
    end

    it "sets reply" do
      expected_reply = Sox::COMMAND::BIND
      actual_request = Sox::Request.new("127.0.0.1", command: expected_reply)

      actual_request.reply.should eq expected_reply
    end

    describe "addr" do
      it "sets ipv4 addr" do
        expected_addr = "225.225.225.225"
        actual_request = Sox::Request.new(addr: expected_addr)

        actual_request.addr.should eq expected_addr
        actual_request.addr_type.should eq Sox::ADDR_TYPE::IPV4
      end

      it "sets ipv6 addr" do
        expected_addr = "0:0:0:0:0:0:0:1"
        actual_request = Sox::Request.new(addr: expected_addr)

        actual_request.addr.should eq expected_addr
        actual_request.addr_type.should eq Sox::ADDR_TYPE::IPV6
      end

      it "sets ipv6 shorts" do
        actual_request = Sox::Request.new(addr: "::1")

        actual_request.addr.should eq "0:0:0:0:0:0:0:1"
        actual_request.addr_type.should eq Sox::ADDR_TYPE::IPV6
      end

      it "sets domain addr" do
        expected_addr = "www.example.com"
        actual_request = Sox::Request.new(addr: expected_addr)

        actual_request.addr.should eq expected_addr
        actual_request.addr_type.should eq Sox::ADDR_TYPE::DOMAIN
      end
    end

    it "raises with invalid addr" do
      expect_raises(Socket::Error) do
        Sox::Request.new(addr: "!@#$")
      end
    end
  end
end
