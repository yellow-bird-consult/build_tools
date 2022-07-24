#!/usr/bin/env bash

# load variables from .env file if present
if [ -f .env ]
then
  export $(cat .env | xargs)
fi

# creates a directory for database management
if [ $2 == "init" ]
then 
    if [ -d ./database_management ]
    then
        echo "database_management is already present"
        exit 0
    else
        mkdir ./database_management
        mkdir ./database_management/1
        touch ./database_management/1/up.sql
        touch ./database_management/1/down.sql
        echo "created database_management directory for managing migrations"
        exit 0
    fi
fi

# exits the script if the database URL is not in the environment variables
if [[ -z "${DB_URL}" ]] 
then
  echo "environment variable DB_URL is not defined"
  exit 1
fi

# swap all : and @ in the URL for /
URL=$(echo ${DB_URL} | tr "(:|@)" "/")

# split the url into an array with / as the delimiter
IFS='/'
read -a strarr <<< "$URL"

# define the parameters for the database
USER=${strarr[3]}
PASSWORD=${strarr[4]}
HOST=${strarr[5]}
PORT=${strarr[6]}
DB=${strarr[7]}

# check to see if the database has a migrations_version table
EXISTING_VERSION_QUERY="SELECT EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'migrations_version');"
VERSION_QUERY="SELECT version FROM migrations_version WHERE id = 1;"
VERSION_PRESENT=$(PGPASSWORD=$(echo $PASSWORD) psql -h $HOST -U $USER -d $DB -p $PORT -t -c "${EXISTING_VERSION_QUERY}")
VERSION_PRESENT=$(echo $VERSION_PRESENT | xargs)

# get the migration version if the table is present
if [ $VERSION_PRESENT == "t" ]
then
    VERSION_NUMBER=$(PGPASSWORD=$(echo $PASSWORD) psql -h $HOST -U $USER -d $DB -p $PORT -t -c "${VERSION_QUERY}")
    VERSION_NUMBER=$(echo $VERSION_NUMBER | xargs)
else
    VERSION_NUMBER="-1"
fi

# define the command on the database
if [ $2 == "get" ]
then
    echo $VERSION_NUMBER

# runs all migrations on the database
elif [ $2 == "run" ]
then
    echo "making run on database"
    TABLE_ALTER_QUERY="UPDATE migrations_version SET version = version + 1 WHERE id = 1;"

    if [ $VERSION_NUMBER == "-1" ]
    then
        echo "database version table is not present you need to run 'yb db set' first to create the table"
        exit 1
    fi

    for file in ./database_management/*
    do
        echo "${file}/up.sql"
        PGPASSWORD=$(echo $PASSWORD) psql -h $HOST -U $USER -d $DB -p $PORT -a -q -f "${file}/up.sql"
        PGPASSWORD=$(echo $PASSWORD) psql -h $HOST -U $USER -d $DB -p $PORT -t -c "${TABLE_ALTER_QUERY}"
    done

# moves the database down a version
elif [ $2 == "down" ]
then 
    if [ $VERSION_NUMBER == "-1" ]
    then
        echo "database version table is not present you need to run 'yb db set' first to create the table"
        exit 1
    fi
    TABLE_ALTER_QUERY="UPDATE migrations_version SET version = version - 1 WHERE id = 1;"
    echo "running down script in version $VERSION_NUMBER"
    echo "./database_management/${NEW_NUMBER}/down.sql"
    PGPASSWORD=$(echo $PASSWORD) psql -h $HOST -U $USER -d $DB -p $PORT -a -q -f "./database_management/${VERSION_NUMBER}/down.sql"
    PGPASSWORD=$(echo $PASSWORD) psql -h $HOST -U $USER -d $DB -p $PORT -t -c "${TABLE_ALTER_QUERY}"

# moves the database up a version
elif [ $2 == "up" ]
then 
    if [ $VERSION_NUMBER == "-1" ]
    then
        echo "database version table is not present you need to run 'yb db set' first to create the table"
        exit 1
    fi
    NEW_NUMBER=$(expr $VERSION_NUMBER + 1)
    TABLE_ALTER_QUERY="UPDATE migrations_version SET version = version + 1 WHERE id = 1;"
    echo "running up script in version $NEW_NUMBER"
    echo "./database_management/${NEW_NUMBER}/up.sql"
    PGPASSWORD=$(echo $PASSWORD) psql -h $HOST -U $USER -d $DB -p $PORT -a -q -f "./database_management/${NEW_NUMBER}/up.sql"
    PGPASSWORD=$(echo $PASSWORD) psql -h $HOST -U $USER -d $DB -p $PORT -t -c "${TABLE_ALTER_QUERY}"

# creates a database version table if not present
elif [ $2 == "set" ]
then
    if [ $VERSION_PRESENT == "t" ]
    then
        echo "migrations_version table is already present"
    else
        TABLE_CREATION_QUERY="CREATE TABLE migrations_version (id int NOT NULL PRIMARY KEY, version integer); INSERT INTO migrations_version(version, id) VALUES (0, 1);"
        PGPASSWORD=$(echo $PASSWORD) psql -h $HOST -U $USER -d $DB -p $PORT -t -c "${TABLE_CREATION_QUERY}"
        echo "migrations_version has been created"
    fi

# creates a new migration directory with the latest version
elif [ $2 == "new" ]
then
    if [ $VERSION_NUMBER == "-1" ]
    then
        echo "database version table is not present you need to run 'yb db set' first to create the table"
        exit 1
    fi
    NEW_NUMBER=$(expr $VERSION_NUMBER + 1)
    if [ -d ./database_management/$NEW_NUMBER ]
    then
        echo "the version ${NEW_NUMBER} already exists"
        echo "you might be on an out of date version in your database as you are currntly tethered to version ${VERSION_NUMBER}"
        echo "ensure you are on the latest version before trying to create a new version"
    else
        mkdir ./database_management/$NEW_NUMBER
        touch ./database_management/$NEW_NUMBER/up.sql
        touch ./database_management/$NEW_NUMBER/down.sql
        echo "created version ${NEW_NUMBER}"
    fi
fi
