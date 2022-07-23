#!/usr/bin/env bash

# work out the platform this is running on
if [ "$(uname)" == "Darwin" ] && [ "$(uname -m)" == "arm64" ]
then
    echo "Apple M1 detected"
    PLATFORM="M1"
elif [ "$(uname)" == "Darwin" ] && [ "$(uname -m)" == "x86_64" ]
then
    echo "Apple Intel detected"
    PLATFORM="AppleIntel"
else
    echo "Linux detected"
    PLATFORM="Linux"
fi

# make yb_tools in root if not there
if [ -d ~/yb_tools ] 
then
    echo "yb_tools already exists... updating" 
else
    echo "yb_tools does not exist... creating"
    mkdir ~/yb_tools
fi

# cd yb_tools

# install wget if not installed
if which wget >/dev/null ; 
then
    echo "wget is installed"
else
    echo "wget is not installed... installing"
    if [ $PLATFORM == "M1" ]
    then
        brew install wget
    elif [ $PLATFORM == "Linux" ]
    then
        apt-get update
        apt-get install wget
    fi
fi

# delete existing static binary
if [ -f ~/yb_tools/build_tool ]
then
    echo "build_tool already exists... removing"
    rm ~/yb_tools/build_tool
fi

# pull static binary
if [ $PLATFORM == "M1" ]
then
    wget https://github.com/yellow-bird-consult/build_tools/raw/develop/releases/build_tools_aarch64_apple_darwin
    mv build_tools_aarch64_apple_darwin ~/yb_tools/build_tool
elif [ $PLATFORM == "Linux" ]
then
    wget https://github.com/yellow-bird-consult/build_tools/raw/develop/releases/build_tools_x86_64_unknown_linux_musl
    mv build_tools_x86_64_unknown_linux_musl ~/yb_tools/build_tool
elif [ $PLATFORM == "AppleIntel" ]
then
    wget https://github.com/yellow-bird-consult/build_tools/raw/develop/releases/build_tools_x86_64_apple_darwin
    mv build_tools_x86_64_apple_darwin ~/yb_tools/build_tool
fi
echo "new build tool installed"

# update the permissions of the static binary
chmod 755 ~/yb_tools/build_tool

if [ -f ~/.zshrc ] 
then 
    if grep -R "alias ybb='~/yb_tools/./build_tool'" ~/.zshrc
    then
        echo "ybb command already exists in ~/.zshrc"
    else
        echo "ybb command does not exist... adding to ~/.zshrc"
        echo "alias ybb='~/yb_tools/./build_tool'" >> ~/.zshrc
    fi 
fi

if [ -f ~/.bashrc ] 
then 
    if grep -R "alias ybb='~/yb_tools/./build_tool'" ~/.bashrc
    then
        echo "ybb command already exists in ~/.bashrc"
    else
        echo "ybb command does not exist... adding to ~/.bashrc"
        echo "alias ybb='~/yb_tools/./build_tool'" >> ~/.bashrc
    fi 
fi

if [ -f ~/.profile ] 
then 
    if grep -R "alias ybb='~/yb_tools/./build_tool'" ~/.profile
    then
        echo "ybb command already exists in ~/.profile"
    else
        echo "ybb command does not exist... adding to ~/.profile"
        echo "alias ybb='~/yb_tools/./build_tool'" >> ~/.profile
    fi 
fi
