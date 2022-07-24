# build_tools

repo for packaging and deploying build tools via static binaries that are built in Rust.

## Installation

Build tools can be installed using the following command:

```bash
wget -O - https://raw.githubusercontent.com/yellow-bird-consult/build_tools/develop/scripts/install.sh | bash
```

## Running on linux

The bash module has to be directly referenced when running on Linux with the following:

```
bash ~/yb_tools/database.sh db get
```
