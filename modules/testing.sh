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

if [ $2 = "local" ]
then
    cp ./platforms/local ./docker-compose.yml
fi

if [ $2 = "deployment" ]
then
    cp ./platforms/deployment ./docker-compose.yml
fi

if [ $2 = "cleanup" ]
then
    rm ./docker-compose.yml
fi



if [ $2 = "integration" ]
then
    # fetch the right build depending on chip
    if [ "$(uname -m)" = "arm64" ]
    then
        cp ./builds/arch_build ./Dockerfile
        cp ./tests/platforms/local ./tests/docker-compose.yml
    else
        cp ./builds/server_build ./Dockerfile
        cp ./tests/platforms/deployment ./tests/docker-compose.yml
    fi
    cd tests 

    if [ $3 = "local" ]
    then 
        cp ./platforms/local ./docker-compose.yml
    else
        cp ./platforms/deployment ./docker-compose.yml
    fi

    # build the system supporting the tests
    docker-compose build --no-cache
    docker-compose up -d

    # wait until rust server is running
    sleep 5

    # run the api tests
    newman run $4.postman_collection.json

    # cleanup containers
    docker-compose down
    rm ../Dockerfile
    rm docker-compose.yml
fi