#!/usr/bin/env bash

SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"
cd $SCRIPTPATH

source ./cross_build.sh
cd releases

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
if [ -d ~/test_yb_tools ] 
then
    echo "test_yb_tools already exists... updating" 
else
    echo "test_yb_tools does not exist... creating"
    mkdir ~/test_yb_tools
fi

# delete existing static binary
if [ -f ~/test_yb_tools/build_tool ]
then
    echo "build_tool already exists... removing"
    rm ~/test_yb_tools/build_tool
fi

# pull static binary
if [ $PLATFORM == "M1" ]
then
    cp build_tools_aarch64_apple_darwin ~/test_yb_tools/build_tool
elif [ $PLATFORM == "Linux" ]
then
    cp build_tools_x86_64_unknown_linux_musl ~/test_yb_tools/build_tool
elif [ $PLATFORM == "AppleIntel" ]
then
    cp build_tools_x86_64_apple_darwin ~/test_yb_tools/build_tool
fi
echo "new build tool installed"

cd ..

# add ingress to build tools
cp modules/ingress.sh ~/test_yb_tools/ingress.sh
echo "added ingress module"
# add db to build tools
cp modules/database.sh ~/test_yb_tools/database.sh
echo "added db module"
cp modules/testing.sh ~/test_yb_tools/testing.sh
echo "added testing module"

# update the permissions of the static binary
chmod 755 ~/test_yb_tools/build_tool

# adding aliases if they do not exist (convert these blocks into functions)
if [ -f ~/.zshrc ] 
then
    # adding direct build alias
    if grep -R "alias tybb='~/test_yb_tools/./build_tool'" ~/.zshrc
    then
        echo "tybb command already exists in ~/.zshrc"
    else
        echo "tybb command does not exist... adding to ~/.zshrc"
        echo "alias tybb='~/test_yb_tools/./build_tool'" >> ~/.zshrc
    fi

    # adding route to ingress alias
    if grep -R "alias tyb='sh ~/test_yb_tools/ingress.sh'" ~/.zshrc
    then
        echo "tyb command already exists in ~/.zshrc"
    else
        echo "tyb command does not exist... adding to ~/.zshrc"
        echo "alias tyb='sh ~/test_yb_tools/ingress.sh'" >> ~/.zshrc
    fi 
fi

if [ -f ~/.bashrc ] 
then 
    # adding direct build alias
    if grep -R "alias tybb='~/test_yb_tools/./build_tool'" ~/.bashrc
    then
        echo "tybb command already exists in ~/.bashrc"
    else
        echo "tybb command does not exist... adding to ~/.bashrc"
        echo "alias tybb='~/test_yb_tools/./build_tool'" >> ~/.bashrc
    fi

    # adding route to ingress alias
    if grep -R "alias tyb='sh ~/test_yb_tools/ingress.sh'" ~/.bashrc
    then
        echo "tyb command already exists in ~/.bashrc"
    else
        echo "tyb command does not exist... adding to ~/.bashrc"
        echo "alias tyb='sh ~/test_yb_tools/ingress.sh'" >> ~/.bashrc
    fi  
fi

if [ -f ~/.profile ] 
then 
    # adding direct build alias
    if grep -R "alias tybb='~/test_yb_tools/./build_tool'" ~/.profile
    then
        echo "tybb command already exists in ~/.profile"
    else
        echo "tybb command does not exist... adding to ~/.profile"
        echo "alias tybb='~/test_yb_tools/./build_tool'" >> ~/.profile
    fi 

    # adding route to ingress alias
    if grep -R "alias tyb='sh ~/test_yb_tools/ingress.sh'" ~/.profile
    then
        echo "tyb command already exists in ~/.profile"
    else
        echo "tyb command does not exist... adding to ~/.profile"
        echo "alias tyb='sh ~/test_yb_tools/ingress.sh'" >> ~/.profile
    fi 
fi
