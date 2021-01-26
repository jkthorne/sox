# Sox

Sox is a library for creating SOCKS5 clients and servers.  Sox is a network proxy and can proxy connections like HTTP requests or ssh connections.  

## Documentation

For more documentation on the specs, this implementation is based on please read documents at  `./docs/specs.`

For more documentation on the implementations of SOCKS, please read documents at  `./docs/`.

## FEATURES
- SOCKS5
    - addr type
        - [x] IPv4 connection
        - [x] IPv6 connection
        - [x] Domain connection
    - Authentication
        - [x] unauthentication
        - [ ] GSS connection
        - [ ] username and password
        - [x] IANA unimplented in ssh
    - command types
        - [x] connect
        - [x] bind
        - [x] udp associate
    - reply / response
        - [x] reply server messages
        - [x] connection response server messages
- SOCKS4
- SOCKS5 server

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  sox:
    github: wontruefree/sox
```

## Usage

A SOCKS Client so to make a connection you have to have a corresponding SOCKS server.  The easiest one to use is ssh.

To start up a local ssh SOCKS server you can connect to yourself.

```bash
# Setup SOCKS on localhost
ssh -D 1080 -C -N 127.0.0.1
```

Have a local SOCKS server directing its connection to a remote host.

```bash
# Setup SOCKS connecting to remote host
ssh -D 1080 -C -N user@remote.com
```

### Basic Usage

#### Basic Socket

To open a SOCKS connection and send a basic HTTP request and get a response.

```crystal
require "sox"

socket = Sox.new(addr: "52.85.89.35")
request = HTTP::Request.new("GET", "/", HTTP::Headers{"Host" => "crystal-lang.org"})

request.to_io(socket)
socket.flush

response = HTTP::Client::Response.from_io(socket)
if response.success?
  puts "Got to crystal through SOCKS5!!!"
end
```

#### Basic Client

`Sox::Client` functions almost like the Crystal [HTTP::Client](https://crystal-lang.org/api/latest/HTTP/Client.html)

```crystal
client = Sox::Client.new("www.example.com", host_addr: "127.0.0.1", host_port: 1080)
response = client.get("/")
puts response.status_code      # => 200
puts response.body.lines.first # => "<!doctype html>"
client.close
```

#### Basic UDP

`Sox::UDP` functions almost like the Crystal [UDPSocket](https://crystal-lang.org/api/latest/UDPSocket.html)

```crystal
server = UDPSocket.new
server.bind "localhost", 9999

client = Sox::UDP.new(host_addr: "127.0.0.1", host_port: 1080)
client.connect "localhost", 9999

client.send "message"
message, client_addr = server.receive

message     # => "message"
client_addr # => Socket::IPAddress(127.0.0.1:50516)

client.close
server.close
```

you can use `Sox::Client` almost like the Crystal [HTTP::Client](https://crystal-lang.org/api/latest/HTTP/Client.html)

```crystal
client = Sox::Client.new("www.example.com", host_addr: "127.0.0.1", host_port: 1080)
response = client.get("/")
puts response.status_code      # => 200
puts response.body.lines.first # => "<!doctype html>"
client.close
```

### Remote server connnection

To open a connection to a remote SOCKS5 Server.


```crystal
require "sox"

socket = Sox.new(host_addr: "gateway.com", addr: "52.85.89.35")
request = HTTP::Request.new("GET", "/", HTTP::Headers{"Host" => "crystal-lang.org"})

request.to_io(socket)
socket.flush

response = HTTP::Client::Response.from_io?(socket)
if response.success?
  puts "Got to crystal through SOCKS5!!!"
end
```

### Connection using none default ports

Sometimes you connect to web servers or remote SOCKS servers on ports that are not default.  This is built into the top level interface no having to deal with requests or connection requests directly.

```crystal
require "sox"

socket = Sox.new(host_addr: "gateway.com" host_port: 8010, addr: "52.85.89.35", port: 3000)
request = HTTP::Request.new("GET", "/", HTTP::Headers{"Host" => "crystal-lang.org"})

request.to_io(socket)
socket.flush

response = HTTP::Client::Response.from_io?(socket)
if response.success?
  puts "Got to crystal through SOCKS5!!!"
end
```

## Specs

Before running specs you should add your public key to the authorized keys.  Please read below if you have not previously set up a socks server for testing.   Although I like Unit Test Spec SOCKS only use tools in the stdlib so this is written in spec style syntax.

### Runnning specs

To run the test suite use the spec command built into crystal.

```bash
crystal spec
```

### Setup SOCKS Server

enable key based authentication for testing

```bash
# enable key based localhost authentication
cat ~/.ssh/id_rsa.pub > ~/.ssh/authorized_keys
```

### TOR
There are some basic tests for a commonly used SOCKS5 server tor.

#### Debian
Install tor via apt.

```bash
sudo apt install tor
```

Optional: Start tor at login and keep tor running in the background.

```bash
systemctl start tor
```

#### MAC

Use homebrew to install tor on your mac.

```bash
brew install tor
```

Optional: Use brew services to keep tor running in the background.

```bash
brew services start tor
```
