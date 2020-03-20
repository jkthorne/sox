require "../sox.cr"
require "http/client"

module Sox
  def self.client(*args)
    Sox::Client.new(*args)
  end
end

class Sox::Client < HTTP::Client
  def initialize(*args, @host_addr : String, @host_port : Int32)
    super(*args)
  end

  def socket
    socket = @socket
    return socket if socket

    hostname = @host.starts_with?('[') && @host.ends_with?(']') ? @host[1..-2] : @host
    socket = Sox.new hostname, @port
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
