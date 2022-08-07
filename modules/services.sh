#!/usr/bin/env bash


if [ ! -f ./Cargo.toml ]
then
    echo "not in a root of a Rust server"
    exit 0
fi

if [ ! -d ./services ]
then
    mkdir services
fi


if [ $2 = "add" ]
then 
    git clone --branch $4 https://github.com/yellow-bird-consult/$3.git ./services/$3
fi

if [ $2 = "wipe" ]
then 
    rm -rf ./services
    mkdir ./services
fi
