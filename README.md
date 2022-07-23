# build_tools

repo for packaging and deploying build tools via static binaries that are built in Rust.

## Installation

Build tools can be installed using the following command:

```bash
wget -O - https://raw.githubusercontent.com/yellow-bird-consult/build_tools/develop/scripts/install.sh | bash
```

Once the installation script has been executed, we need to define the following alias in our profile:

```bash
 ybb='~/yb_tools/./build_tool'
```
