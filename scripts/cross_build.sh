#!/usr/bin/env bash

SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"
cd $SCRIPTPATH

cargo install cross --git https://github.com/cross-rs/cross

git clone https://github.com/cross-rs/cross

cd cross
git submodule update --init --remote
cd ..

rm -rf cross

cd ..

# https://github.com/cross-rs/cross#supported-targets
cross build --target x86_64-unknown-linux-musl --release
cross build --target aarch64-apple-darwin --release
cross build --target x86_64-apple-darwin --release

cp ./target/aarch64-apple-darwin/release/build_tools ./releases/build_tools_aarch64_apple_darwin
cp ./target/x86_64-unknown-linux-musl/release/build_tools ./releases/build_tools_x86_64_unknown_linux_musl
cp ./target/x86_64-apple-darwin/release/build_tools ./releases/build_tools_x86_64_apple_darwin
