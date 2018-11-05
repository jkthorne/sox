require "socket"

class Socks < IPSocket
  V4 = 4_u8
  V5 = 5_u8
  BLANK_BYTE = 0_u8
  RESERVED = BLANK_BYTE            ## dont need to allocate more 0_u8
  MARK_BYTE = 255_u8

  module AUTH
    NO_AUTHENTICATION     = 0_u8
    GSSAPI                = 1_u8
    USERNAME_PASSWORD     = 2_u8
    IANA                  = 3_u8   ## X'03' to X'7F' IANA ASSIGNED
    RESERVED              = 80_u8  ## o  X'80' to X'FE' RESERVED FOR PRIVATE METHODS
    NO_ACCEPTABLE_METHODS = 255_u8
  end

  module COMMAND
    CONNECT       = 1_u8
    BIND          = 2_u8
    UDP_ASSOCIATE = 3_u8
  end

  module ADDR_TYPE
    IPV4   = 1_u8
    IPV6   = 4_u8
    DOMAIN = 3_u8
  end

  def initialize(addr : String, port : Int = 80, host_addr : String = "127.0.0.1", host_port : Int = 1080,
                 command : (UInt8|Symbol) = COMMAND::CONNECT)
    if command == COMMAND::CONNECT || command == :connect
      Addrinfo.tcp(host_addr, host_port, timeout: nil) do |addrinfo|
        super(addrinfo.family, addrinfo.type, addrinfo.protocol)
        connect(addrinfo, timeout: nil) do |error|
          close
          error
        end
      end
      main_connect(addr, port)
    elsif command == COMMAND::UDP_ASSOCIATE || command == :udp
      Addrinfo.udp(host_addr, host_port, timeout: nil) do |addrinfo|
        super(addrinfo.family, addrinfo.type, addrinfo.protocol)
        connect(addrinfo, timeout: nil) do |error|
          close
          error
        end
      end
    else
      raise "invalid command type"
    end
  end

  def main_connect(addr : String, port : Int)
    connect_host
    connect_remote(addr, port)
  end

  def connect_host
    connection_request = ConnectionRequest.new
    write(connection_request.buffer)

    connection_response = ConnectionResponse.new
    read(connection_response.buffer)
    self
  end

  def connect_remote(addr : String, port : Int)
    request = Request.new(addr: addr, port: port)
    write(request.buffer)

    reply = Reply.new(buffer_size: request.size)
    read(reply.buffer)
    self
  end

  # def initialize(addr : String, port : Int = 80, host_addr : String = "127.0.0.1",
  #   host_port : Int = 1080, command : UInt8 = COMMAND::CONNECT)
  # super(Family::INET, Type::DGRAM, Protocol::UDP)
  # connect(addr, port)
  # end

  def receive(max_message_size = 512) : {String, IPAddress}
    address = nil
    message = String.new(max_message_size) do |buffer|
      bytes_read, sockaddr, addrlen = recvfrom(Slice.new(buffer, max_message_size))
      address = IPAddress.from(sockaddr, addrlen)
      {bytes_read, 0}
    end
    {message, address.not_nil!}
  end

  def receive(message : Bytes) : {Int32, IPAddress}
    bytes_read, sockaddr, addrlen = recvfrom(message)
    {bytes_read, IPAddress.from(sockaddr, addrlen)}
  end

  def self.open(host, port)
    sock = new(host, port)
    begin
      yield sock
    ensure
      sock.close
    end
  end

  def tcp_nodelay?
    getsockopt_bool LibC::TCP_NODELAY, level: Protocol::TCP
  end

  def tcp_nodelay=(val : Bool)
    setsockopt_bool LibC::TCP_NODELAY, val, level: Protocol::TCP
  end

  {% unless flag?(:openbsd) %}
    # The amount of time in seconds the connection must be idle before sending keepalive probes.
    def tcp_keepalive_idle
      optname = {% if flag?(:darwin) %}
        LibC::TCP_KEEPALIVE
      {% else %}
        LibC::TCP_KEEPIDLE
      {% end %}
      getsockopt optname, 0, level: Protocol::TCP
    end

    def tcp_keepalive_idle=(val : Int)
      optname = {% if flag?(:darwin) %}
        LibC::TCP_KEEPALIVE
      {% else %}
        LibC::TCP_KEEPIDLE
      {% end %}
      setsockopt optname, val, level: Protocol::TCP
      val
    end

    def tcp_keepalive_interval
      getsockopt LibC::TCP_KEEPINTVL, 0, level: Protocol::TCP
    end

    def tcp_keepalive_interval=(val : Int)
      setsockopt LibC::TCP_KEEPINTVL, val, level: Protocol::TCP
      val
    end

    def tcp_keepalive_count
      getsockopt LibC::TCP_KEEPCNT, 0, level: Protocol::TCP
    end

    def tcp_keepalive_count=(val : Int)
      setsockopt LibC::TCP_KEEPCNT, val, level: Protocol::TCP
      val
    end
  {% end %}
end

require "./connection_request.cr"
require "./connection_response.cr"
require "./request.cr"
require "./reply.cr"
