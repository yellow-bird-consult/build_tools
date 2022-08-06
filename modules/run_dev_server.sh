#!/usr/bin/env bash

# load variables from .env file if present
if [ -f .env ]
then
  export $(cat .env | xargs)
fi

cargo run
