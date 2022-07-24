#!/bin/bash

# do the routing for incoming traffic
if [ $1 = "db" ]
then
    source ~/test_yb_tools/database.sh
elif [ $1 = "build" ]
then
    ~/test_yb_tools/./build_tool
fi
