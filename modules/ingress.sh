#!/bin/bash

# do the routing for incoming traffic
if [ $1 = "db" ]
then
    source ~/test_yb_tools/database.sh
elif [ $1 = "build" ]
then
    ~/test_yb_tools/./build_tool
elif [ $1 = "test" ]
then
    ~/test_yb_tools/testing.sh
elif [ $1 = "run" ]
then
    ~/test_yb_tools/run_dev_server.sh
fi
