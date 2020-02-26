require "../src/sox"
require "http/client"

socket = Sox.new(addr: "99.84.248.30")
request = HTTP::Request.new("GET", "/", HTTP::Headers{"Host" => "crystal-lang.org"})

request.to_io(socket)
socket.flush

response = HTTP::Client::Response.from_io(socket)
pp response
if response.success?
  puts "Got to crystal through SOCKS5!!!"
end
