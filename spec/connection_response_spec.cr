require "./spec_helper"

describe Sox::ConnectionResponse do
  it "default buffer" do
    expected_version = Sox::V5
    expected_method = Sox::AUTH::NO_AUTHENTICATION
    actual_response = Sox::ConnectionResponse.new
    IO::Memory.new(Bytes[expected_version, expected_method]).read(actual_response.buffer)

    actual_response.version.should eq expected_version
    actual_response.method.should eq expected_method
  end

  it "#connected?" do
    actual_response = Sox::ConnectionResponse.new

    IO::Memory.new(Bytes[Sox::V5, Sox::AUTH::NO_AUTHENTICATION]).read(actual_response.buffer)

    actual_response.connected?.should eq true
  end

  describe "#server_message" do
    it "supported versions" do
      expected_version = 100_u8
      actual_response = Sox::ConnectionResponse.new

      IO::Memory.new(Bytes[expected_version, Sox::AUTH::NO_AUTHENTICATION]).read(actual_response.buffer)

      actual_response.server_message.should eq "SOCKS version #{expected_version} not supported"
    end

    it "supported methods" do
      expected_method = 100_u8
      actual_response = Sox::ConnectionResponse.new

      IO::Memory.new(Bytes[Sox::V5, expected_method]).read(actual_response.buffer)

      actual_response.server_message.should eq "SOCKS authentication method #{expected_method} neither requested nor supported"
    end

    it "connected" do
      actual_response = Sox::ConnectionResponse.new

      IO::Memory.new(Bytes[Sox::V5, Sox::AUTH::NO_AUTHENTICATION]).read(actual_response.buffer)

      actual_response.server_message.should eq "Server connected"
    end
  end
end
