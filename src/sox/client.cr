require "../sox.cr"
require "http/client"

module SoxClient
  def self.client(*args)
    Sox::Client.new(*args)
  end
end

class Sox::Client < HTTP::Client
  def initialize(*args, @proxy_addr : String, @proxy_port : Int32, tls : TLSContext = nil)
    super(*args)
  end

  def socket
    socket = @socket
    return socket if socket

    proxy_addr = @proxy_addr.starts_with?('[') && @proxy_addr.ends_with?(']') ? @proxy_addr[1..-2] : @proxy_addr
    socket = Sox.new host: proxy_addr, port: @proxy_port
    socket.read_timeout = @read_timeout if @read_timeout
    socket.sync = false
    @socket = socket

    {% if !flag?(:without_openssl) %}
      if tls = @tls
        tls_socket = OpenSSL::SSL::Socket::Client.new(socket, context: tls, sync_close: true, hostname: @host)
        @socket = socket = tls_socket
      end
    {% end %}
    socket
  end
end
