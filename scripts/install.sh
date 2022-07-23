#!/usr/bin/env bash

cd ~

# work out the platform this is running on
if [ "$(uname)" == "Darwin" ] && [ "$(uname -m)" == "arm64" ]
then
    echo "Apple M1 detected"
    PLATFORM="M1"
else
    echo "Linux detected"
    PLATFORM="Linux"
fi

# make yb_tools in root if not there
if [ -d "./yb_tools" ] 
then
    echo "yb_tools does exist... creating" 
else
    echo "yb_tools already exists... updating"
    mkdir yb_tools
fi

cd yb_tools

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
if [ -d "./build_tool" ]
then
    rm ./build_tool
fi

# pull static binary
if [ $PLATFORM == "M1" ]
then
    wget https://github.com/yellow-bird-consult/build_tools/raw/develop/releases/build_tools_aarch64_apple_darwin
    mv build_tools_aarch64_apple_darwin build_tool
elif [ $PLATFORM == "Linux" ]
then
    https://github.com/yellow-bird-consult/build_tools/raw/develop/releases/build_tools_x86_64_unknown_linux_musl
    mv build_tools_x86_64_unknown_linux_musl build_tool
fi

# update the permissions of the static binary
chmod 755 ./build_tool

echo "\n\n\n\nYellow Bird build tools have been installed"
echo "please add the following alias to your profile:"
echo "\n\nalias ybb='~/yb_tools/./build_tool'\n\n"

# configure the alias for the terminal
# if alias ybb 2>/dev/null; 
# then 
#   echo "ybb already defined"
# else
#   echo "ybb cannot be detected"
#   if [ $PLATFORM == "M1" ]
#   then
#     echo "adding alias ybb to zsh"
#     echo "alias ybb='~/yb_tools/./build_tool'" >> ~/.zshrc

#   elif [ $PLATFORM == "Linux" ]
#     then
#         if [ -f "~/.bashrc" ]
#         then
#           echo "alias ybb='~/yb_tools/./build_tool'" >> ~/.bashrc
#         fi
#         if [ -f "~/.bash_login" ]
#         then
#           echo "alias ybb='~/yb_tools/./build_tool'" >> ~/.bash_login
#         fi
#         if [ -f "~/.profile" ]
#         then
#           echo "alias ybb='~/yb_tools/./build_tool'" >> ~/.profile
#         fi
#     fi
# fi
