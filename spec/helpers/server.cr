require "http/server"

class Factory
  def self.server
    @@server ||= HTTP::Server.new do |context|
      context.response.content_type = "text/plain"
      if context.request.path == "/ping"
        context.response.puts "pong"
      end
    end
  end
end
