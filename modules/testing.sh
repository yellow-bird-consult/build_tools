#!/usr/bin/env bash

# load variables from .env file if present
if [ -f .env ]
then
  export $(cat .env | xargs)
fi

# creates a directory for database management
if [ $2 = "init" ]
then 
    if [ -d ./test_meta ]
    then
        echo "test_meta is already present"
        exit 0
    else
        mkdir ./test_meta
        touch ./test_meta/1/docker-compose.yml
        echo "created test_meta directory for housing testing data"
        exit 0
    fi
fi

