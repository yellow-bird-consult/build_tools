#!/usr/bin/env bash

if [ ! -d ./services ]
then
    mkdir services
fi

# work out the platform this is running on
if [ "$(uname)" = "Darwin" ] && [ "$(uname -m)" = "arm64" ]
then
    echo "Apple M1 detected"
    PLATFORM="M1"
elif [ "$(uname)" = "Darwin" ] && [ "$(uname -m)" = "x86_64" ]
then
    echo "Apple Intel detected"
    PLATFORM="AppleIntel"
else
    echo "Linux detected"
    PLATFORM="Linux"
fi

if [ $2 = "add" ]
then 
    git clone --branch $4 https://github.com/yellow-bird-consult/$3.git ./services/$3
    cd ./services/$3
    if [ $PLATFORM = "M1" ]
    then
        cp ./builds/arch_build ./Dockerfile
    elif [ $PLATFORM = "Linux" ]
    then
        cp ./builds/server_build ./Dockerfile
    elif [ $PLATFORM = "AppleIntel" ]
    then
        cp ./builds/server_build ./Dockerfile
    fi
fi

if [ $2 = "wipe" ]
then 
    rm -rf ./services
    mkdir ./services
fi

# Add a refresh 
# Add a switch branch
# add an ls
# Add environment variables .env file in the build tools directory => GIT_OWNER=yellow-bird-consult
