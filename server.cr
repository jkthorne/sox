require "http/server"

server = HTTP::Server.new do |context|
  context.response.content_type = "text/plain"
  context.response.print "Hello world!\n"
  puts "Processed Request"
end

address = server.bind_tcp 80
puts "Listening on http://#{address}"
server.listen
