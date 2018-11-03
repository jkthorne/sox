# socks

Socks is a network proxy and can be used for proxying connections like your http clint or ssh connections.  "Socks" Socks is a generic Socks proxy library implementing all the features of the Socks specs.

## Documentation

For more ducumentation on the specs and usage of Socks itself look in the `./docs/` directory.

## FEATURES
- [ ] SocksV5

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  socks:
    github: wontruefree/socks
```

## Usage

```crystal
require "socks"
```

In one terminal run
```bash
ssh -D 1080 -C -N 127.0.0.1 -vv
```

Then in the other run
```bash
crystal src/socks.cr
```

## Specs
Before running specs you should add your public key to the authorized keys.
This makes setting up a socks for testing eaiser.

```bash
cat ~/.ssh/id_rsa.pub > ~/.ssh/authorized_keys
```

You will also need to start tor.
