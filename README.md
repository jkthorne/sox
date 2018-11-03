# socks

Socks is a network proxy and can be used for proxying connections like your http clint or ssh connections.  "Socks" Socks is a generic Socks proxy library implementing all the features of the Socks specs.

## Documentation

For more ducumentation on the specs and usage of Socks itself look in the `./Documentation/` directory.

## FEATURES
- SOCKSV5
	- addr type
		- [x] IPv4 connection
		- [ ] IPv6 connection
		- [ ] Domain connection
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
- SOCKSV4

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  socks:
    github: wontruefree/socks
```

## Usage
This is a SOCKS Client so to make a connection you have to have a corisponding SOCKS server.  The eaisest one to use is ssh.

To startup a local ssh SOCKS server you can connect to yourself.

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
To open a socks connection and send a basic HTTP request and get a response.

```crystal
require "socks"

socket = Socks.new(addr: "52.85.89.35", port: 80)
request = HTTP::Request.new("GET", "/", HTTP::Headers{"Host" => "crystal-lang.org"})

request.to_io(socket)
socket.flush

response = HTTP::Client::Response.from_io?(socket)
if response.success?
  puts "Got to crystal through SOCKS5!!!"
end
```

## Specs
Before running specs you should add your public key to the authorized keys.
This makes setting up a socks for testing eaiser.

### Runnning specs

Please read below if you have not previuosly setup a socks server for testing.   Although I like Unit Test Spec SOCKS trys and only use tools in the stdlib so this is written in spec style syntax.

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
There are some basic tests for a commenly used SOCKS5 server tor.

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
