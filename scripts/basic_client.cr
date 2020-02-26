require "../src/sox/client"

client = Sox::Client.new("www.example.com", host_addr: "127.0.0.1", host_port: 1080)
response = client.get("/")
puts response.status_code      # => 200
puts response.body.lines.first # => "<!doctype html>"
client.close
