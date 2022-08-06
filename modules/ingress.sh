#!/bin/bash

# do the routing for incoming traffic
if [ $1 = "db" ]
then
    source ~/yb_tools/database.sh
elif [ $1 = "build" ]
then
    ~/yb_tools/./build_tool
elif [ $1 = "test" ]
then
    source ~/yb_tools/testing.sh
elif [ $1 = "run" ]
then
    ~/yb_tools/run_dev_server.sh
fi
