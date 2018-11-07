require "../socks.cr"
require "http/client"

class Socks::Client < HTTP::Client
  def initialize(*args, @host_addr : String, @host_port : Int32)
    super(*args)
  end

  def socket
    socket = @socket
    STDOUT.puts "1"
    return socket if socket

    hostname = @host.starts_with?('[') && @host.ends_with?(']') ? @host[1..-2] : @host
    STDOUT.puts "2"
    pp! hostname, @port
    socket = Socks.new hostname, @port
    STDOUT.puts "2.1"
    socket.read_timeout = @read_timeout if @read_timeout
    socket.sync = false
    STDOUT.puts "3"
    @socket = socket

    {% if !flag?(:without_openssl) %}
      if tls = @tls
        tls_socket = OpenSSL::SSL::Socket::Client.new(socket, context: tls, sync_close: true, hostname: @host)
        @socket = socket = tls_socket
      end
    {% end %}
    STDOUT.puts "4"
    socket
  end
end

client = Socks::Client.new("www.example.com", host_addr: "127.0.0.1", host_port: 1080)
response = client.get("/")
pp! response.status_code      # => 200
pp! response.body.lines.first # => "<!doctype html>"
client.close
