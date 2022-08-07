#!/usr/bin/env bash

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

# make yb_tools in root if not there
if [ -d ~/yb_tools ] 
then
    echo "yb_tools already exists... updating" 
else
    echo "yb_tools does not exist... creating"
    mkdir ~/yb_tools
fi

# delete existing static binary
if [ -f ~/yb_tools/build_tool ]
then
    echo "build_tool already exists... removing"
    rm ~/yb_tools/build_tool
fi

# pull static binary
if [ $PLATFORM = "M1" ]
then
    wget https://github.com/yellow-bird-consult/build_tools/raw/develop/releases/build_tools_aarch64_apple_darwin
    mv build_tools_aarch64_apple_darwin ~/yb_tools/build_tool
elif [ $PLATFORM = "Linux" ]
then
    wget https://github.com/yellow-bird-consult/build_tools/raw/develop/releases/build_tools_x86_64_unknown_linux_musl
    mv build_tools_x86_64_unknown_linux_musl ~/yb_tools/build_tool
elif [ $PLATFORM = "AppleIntel" ]
then
    wget https://github.com/yellow-bird-consult/build_tools/raw/develop/releases/build_tools_x86_64_apple_darwin
    mv build_tools_x86_64_apple_darwin ~/yb_tools/build_tool
fi
echo "new build tool installed"

# delete existing bash modules
if [ -f ~/yb_tools/ingress.sh ]
then
    rm ~/yb_tools/ingress.sh
    echo "existing ingress bash module deleted"
fi
if [ -f ~/yb_tools/database.sh ]
then
    rm ~/yb_tools/database.sh
    echo "existing database bash module deleted"
fi  

# pull bash ingress and modules
wget -q https://github.com/yellow-bird-consult/build_tools/raw/develop/modules/ingress.sh
wget -q https://github.com/yellow-bird-consult/build_tools/raw/develop/modules/database.sh
wget -q https://github.com/yellow-bird-consult/build_tools/raw/develop/modules/testing.sh
wget -q https://github.com/yellow-bird-consult/build_tools/raw/develop/modules/run_dev_server.sh
wget -q https://github.com/yellow-bird-consult/build_tools/raw/develop/modules/services.sh

# move bash ingress and modules to yb_tools
mv ingress.sh ~/yb_tools/ingress.sh
mv database.sh ~/yb_tools/database.sh
mv testing.sh ~/yb_tools/testing.sh
mv run_dev_server.sh ~/yb_tools/run_dev_server.sh
mv services.sh ~/yb_tools/services.sh
chmod u+x ~/yb_tools/ingress.sh
chmod u+x ~/yb_tools/database.sh
chmod u+x ~/yb_tools/testing.sh
chmod u+x ~/yb_tools/run_dev_server.sh
chmod u+x ~/yb_tools/services.sh
echo "ingress bash module installed"
echo "database bash module installed"
echo "testing bash module installed"
echo "run dev server bash module installed"
echo "services bash module installed"

# update the permissions of the static binary
chmod 755 ~/yb_tools/build_tool

# add alias to profiles if not present
if [ -f ~/.zshrc ] 
then 
    # adding direct build alias
    if grep -R "alias ybb='~/yb_tools/./build_tool'" ~/.zshrc
    then
        echo "ybb command already exists in ~/.zshrc"
    else
        echo "ybb command does not exist... adding to ~/.zshrc"
        echo "alias ybb='~/yb_tools/./build_tool'" >> ~/.zshrc
    fi

    # adding route to ingress alias
    if grep -R "alias yb='sh ~/yb_tools/ingress.sh'" ~/.zshrc
    then
        echo "yb command already exists in ~/.zshrc"
    else
        echo "yb command does not exist... adding to ~/.zshrc"
        echo "alias yb='sh ~/yb_tools/ingress.sh'" >> ~/.zshrc
    fi 
fi

if [ -f ~/.bashrc ] 
then 
    # adding direct build alias
    if grep -R "alias ybb='~/yb_tools/./build_tool'" ~/.bashrc
    then
        echo "ybb command already exists in ~/.bashrc"
    else
        echo "ybb command does not exist... adding to ~/.bashrc"
        echo "alias ybb='~/yb_tools/./build_tool'" >> ~/.bashrc
    fi

    # adding route to ingress alias
    if grep -R "alias yb='sh ~/yb_tools/ingress.sh'" ~/.bashrc
    then
        echo "yb command already exists in ~/.bashrc"
    else
        echo "yb command does not exist... adding to ~/.bashrc"
        echo "alias yb='sh ~/yb_tools/ingress.sh'" >> ~/.bashrc
    fi 
fi

if [ -f ~/.profile ] 
then 
    # adding direct build alias
    if grep -R "alias ybb='~/yb_tools/./build_tool'" ~/.profile
    then
        echo "ybb command already exists in ~/.profile"
    else
        echo "ybb command does not exist... adding to ~/.profile"
        echo "alias ybb='~/yb_tools/./build_tool'" >> ~/.profile
    fi

    # adding route to ingress alias
    if grep -R "alias yb='sh ~/yb_tools/ingress.sh'" ~/.profile
    then
        echo "yb command already exists in ~/.profile"
    else
        echo "yb command does not exist... adding to ~/.profile"
        echo "alias yb='sh ~/yb_tools/ingress.sh'" >> ~/.profile
    fi  
fi
