# socks

This is a socks 5 implementatino

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
