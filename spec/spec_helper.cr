require "spec"
require "../src/socks"
require "http/server"

#PORT = rand(8000..10000)
PORT = ENV["PORT"].to_i


# `ssh -D 1080 -C -N 127.0.0.1`

#pp! Process.new("ssh -D #{PORT} -C -N root@167.99.184.241")
#pp! `ssh -D #{PORT} -C -N root@167.99.184.241`

#sock = Socket.tcp(Socket::Family::INET6)
#sock.bind Socket::IPAddress.new("127.0.0.1", PORT)
