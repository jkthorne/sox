require "http/server"

server = HTTP::Server.new do |context|
  pp! context if ENV["DEBUG"] == "true"
  context.response.content_type = "text/plain"
  if context.request.path == "/ping"
    context.response.puts "pong"
  end
end

server.bind_tcp 8080
server.listen
