require "spec"
require "../src/socks"
require "http/server"

SSH_PORT = rand(8000..10000)
SSH_PROCESS = Process.new("ssh", ["-D", SSH_PORT.to_s, "-C", "-N", "127.0.0.1"])
sleep(0.5) ## Waiting for ssh to start

at_exit {
  SSH_PROCESS.kill
}
