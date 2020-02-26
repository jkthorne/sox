require "./spec_helper"

private def default_bytes
  Bytes[
    Sox::V5, Sox::COMMAND::CONNECT, 0_u8, Sox::ADDR_TYPE::IPV4,
    0_u8, 0_u8, 0_u8, 0_u8, 0_u8, 0_u8,
  ].clone
end

describe Sox::Reply do
  it "default buffer" do
    expected_bytes = default_bytes
    actual_response = Sox::Reply.new
    IO::Memory.new(expected_bytes).read(actual_response.buffer)

    actual_response.version.should eq Sox::V5
    actual_response.reply.should eq Sox::COMMAND::CONNECT
    actual_response.addr.should eq "0.0.0.0"
    actual_response.port.should eq 0
  end

  describe "#addr" do
    it "ip4v addr" do
      expected_bytes = default_bytes
      actual_response = Sox::Reply.new

      IO::Memory.new(expected_bytes).read(actual_response.buffer)

      actual_response.addr.should eq "0.0.0.0"
    end

    it "ip6v addr" do
      expected_bytes = Bytes[
        Sox::V5, 0_u8, 0_u8, Sox::ADDR_TYPE::IPV6,
        0_u8, 0_u8, 0_u8, 0_u8, 0_u8, 0_u8, 0_u8, 0_u8, 0_u8,
        0_u8, 0_u8, 0_u8, 0_u8, 0_u8, 0_u8, 0_u8, 0_u8, 0_u8,
      ].clone
      actual_response = Sox::Reply.new(expected_bytes.size)

      IO::Memory.new(expected_bytes).read(actual_response.buffer)

      actual_response.addr.should eq "0:0:0:0:0:0:0:0"
    end

    it "domain addr" do
      expected_bytes = Bytes[
        Sox::V5, 0_u8, 0_u8, Sox::ADDR_TYPE::DOMAIN, 15_u8,
        119_u8, 119_u8, 119_u8, 46_u8, 101_u8, 120_u8, 97_u8,
        109_u8, 112_u8, 108_u8, 101_u8, 46_u8, 99_u8, 111_u8,
        109_u8, 0_u8, 0_u8,
      ].clone
      actual_response = Sox::Reply.new(expected_bytes.size)

      IO::Memory.new(expected_bytes).read(actual_response.buffer)

      actual_response.addr.should eq "www.example.com"
    end
  end

  describe "#server_message" do
    it "supported versions" do
      expected_bytes = default_bytes
      expected_version = 100_u8
      expected_bytes[0] = expected_version
      actual_response = Sox::Reply.new

      IO::Memory.new(expected_bytes).read(actual_response.buffer)

      actual_response.server_message.should eq "SOCKS version #{expected_version} is not supported"
    end

    it "supported addr types" do
      expected_bytes = default_bytes
      expected_addr_type = 100_u8
      expected_bytes[3] = expected_addr_type
      actual_response = Sox::Reply.new

      IO::Memory.new(expected_bytes).read(actual_response.buffer)

      actual_response.server_message.should eq "ADDR type not supported"
    end

    it "successful response" do
      expected_bytes = default_bytes
      actual_response = Sox::Reply.new

      IO::Memory.new(expected_bytes).read(actual_response.buffer)

      actual_response.server_message.should eq "succeeded"
    end

    it "supported general failure" do
      expected_bytes = default_bytes
      expected_reply = 1_u8
      expected_bytes[2] = expected_reply
      actual_response = Sox::Reply.new

      IO::Memory.new(expected_bytes).read(actual_response.buffer)

      actual_response.server_message.should eq "general SOCKS server failure"
    end

    it "supported connection rulesets" do
      expected_bytes = default_bytes
      expected_reply = 2_u8
      expected_bytes[2] = expected_reply
      actual_response = Sox::Reply.new

      IO::Memory.new(expected_bytes).read(actual_response.buffer)

      actual_response.server_message.should eq "connection not allowed by ruleset"
    end

    it "supported Network unreachable" do
      expected_bytes = default_bytes
      expected_reply = 3_u8
      expected_bytes[2] = expected_reply
      actual_response = Sox::Reply.new

      IO::Memory.new(expected_bytes).read(actual_response.buffer)

      actual_response.server_message.should eq "Network unreachable"
    end

    it "supported Host unreachable" do
      expected_bytes = default_bytes
      expected_reply = 4_u8
      expected_bytes[2] = expected_reply
      actual_response = Sox::Reply.new

      IO::Memory.new(expected_bytes).read(actual_response.buffer)

      actual_response.server_message.should eq "Host unreachable"
    end

    it "supported Connection refused" do
      expected_bytes = default_bytes
      expected_reply = 5_u8
      expected_bytes[2] = expected_reply
      actual_response = Sox::Reply.new

      IO::Memory.new(expected_bytes).read(actual_response.buffer)

      actual_response.server_message.should eq "Connection refused"
    end

    it "supported TTL expired" do
      expected_bytes = default_bytes
      expected_reply = 6_u8
      expected_bytes[2] = expected_reply
      actual_response = Sox::Reply.new

      IO::Memory.new(expected_bytes).read(actual_response.buffer)

      actual_response.server_message.should eq "TTL expired"
    end

    it "supported TTL expired" do
      expected_bytes = default_bytes
      expected_reply = 6_u8
      expected_bytes[2] = expected_reply
      actual_response = Sox::Reply.new

      IO::Memory.new(expected_bytes).read(actual_response.buffer)

      actual_response.server_message.should eq "TTL expired"
    end

    it "supported Command not supported" do
      expected_bytes = default_bytes
      expected_reply = 7_u8
      expected_bytes[2] = expected_reply
      actual_response = Sox::Reply.new

      IO::Memory.new(expected_bytes).read(actual_response.buffer)

      actual_response.server_message.should eq "Command not supported"
    end

    it "supported Address type not supported" do
      expected_bytes = default_bytes
      expected_reply = 8_u8
      expected_bytes[2] = expected_reply
      actual_response = Sox::Reply.new

      IO::Memory.new(expected_bytes).read(actual_response.buffer)

      actual_response.server_message.should eq "Address type not supported"
    end
  end
end
