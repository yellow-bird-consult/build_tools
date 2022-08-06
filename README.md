# build_tools

repo for packaging build tools that help with the management and deployment of web applications. Build tools currently
has the following features:

- database migration management
- testing pipelines for web apps, docker-compose, and Newman

## Installation

Build tools can be installed using the following command:

```bash
wget -O - https://raw.githubusercontent.com/yellow-bird-consult/build_tools/develop/scripts/install.sh | bash
```

## Running on linux

The build tools have aliases that we will referenced throughout the documentation. However, whilst the aliases
work on Macs, they can be fiddly with Linux. As a result, the bash script modules can be directly referenced
as seen in the example below:

```bash
bash ~/yb_tools/database.sh db get
```

Each bash script module is completely isolated so feel free to pull them around and use them as you see
fit.

## Running a Rust dev server

To run a Rust dev server you need to navigate to the directory where your ```Cargo.toml``` file is. This tool assumes that
you use environment variables to configure your server or any Rust application in debug mode. Because of the environment
variable assumption, you will need an ```.env``` file in the same directory as your ```Cargo.toml``` file. For our example
our ```.env``` file takes the following form:

```.env
DB_URL="postgres://username:password@localhost:5433/auth"
SECRET_KEY="secret"
EXPIRE_MINUTES="60"
ORG_EMAIL="@yellowbirdconsulting.co.uk"
PRODUCTION="false"
```

We can see that we have defined a basic set of parameters for a toy dev server. We can then run our server with the
following command:

```bash
# with alias
yb run

# without alias
bash ~/test_yb_tools/run_dev_server.sh run
```

The parameters from the ```.env``` file will be exported into the server run.

## Database migrations

Build tools manages database migrations. However, before we go further we must explain what the motivation is behind this tool
and its features before you make the decision on if this tool is right for you. Yellow Bird's migration tool is designed
for microservices. We wanted to completely de-couple the programming language of the web application with the management of
the database. Its only dependency is [psql](https://www.postgresql.org/docs/current/app-psql.html). The database URL is
only loaded through an ```.env``` file or an environment variable. This makes it perfect for init pods, containers etc.
However, with this lightweight approach guard rails have been taken off.

### Use yb database migrations if you have the following

- **a light throughput of migrations:** migrations are not timestamped but simply numbered. The design is simple
  to keep track of what's going on. Light applications in microservices is an ideal environment.
- **well tested code:** There are no guard rails, if there is an error in part of your SQL script, your database will
  be scarred with a part run migration. You should have testing regimes with Docker databases before implementing
  migrations on a live production database
- **you plan on writing your own SQL:** Because this tool is completely decoupled from any programming language you have
  to write your own SQL scripts for each migration. This is not as daunting as you might think and gives you more control.
- **you want complete control:** The result of SQL migrations and the simple implementation that is essentially defined
  in a single Bash script. This simple implementation gives you 100% control. There is nothing stopping you from opening
  up your database in a GUI and directly altering the version number or manually running particular sections of the migration.

Complete control sounds good but you have to be careful. You can use this tool to keep technical debt low. However, there are
more ways in which you can shoot yourself in the foot. This tool is not the best or worst. If you're confident in your
system/abilities and you want to keep everything decoupled then this is the tool for you. If you're not interested in SQL
and you think that less control and more technical debt is a good trade-off for safety and ease of use then there are
plenty of ORMs in every language that will be a better fit for your needs.

### Setup a migration

Once you have yb tools installed, we have to define the database migrations folder. If you are having trouble with the
alias as there is problems with some Linux distributions, we can create the migrations file with the following command:

```bash
bash ~/yb_tools/database.sh db init
```

if the alias does work for you then you can use the command below:

```bash
yb db init
```

This will create the following structure:

```bash
├── database_management
│   └── 1
│       ├── down.sql
│       └── up.sql
```

The number is the number of a migration. The ```up.sql``` script is run when we move the migration up one. The ```down.sql```
script is run when then migration is moved down one. In this example we will create some simple tables in the ```up.sql```
script with the code below:

```sql
CREATE TABLE users (
    id SERIAL NOT NULL PRIMARY KEY,
    username varchar(80) NOT NULL UNIQUE,
    email varchar(120) UNIQUE
);


CREATE TABLE user_institution (
    id SERIAL NOT NULL PRIMARY KEY,
    user_id integer,
    institution_id integer
);
```

For the ```down.sql``` file we will have the following code to drop the tables:

```sql
DROP TABLE users;
DROP TABLE user_institution;
```

Before we run any migrations however, we need to define the database and environment variables. Remember, the migration tool is
dependent of environment variables for the database URL. This is to make it easy for docker pods and kubernetes, and it also
forces the developer to keep the migrations system 100% isolated from the web application code. Our ```docker-compose.yml```
takes the following form:

```yml
version: "3.7"

services:
    postgres:
      container_name: 'build-tools-dev-postgres'
      image: 'postgres'
      restart: always
      ports:
        - '5433:5432'
      environment:
        - 'POSTGRES_USER=user'
        - 'POSTGRES_DB=admin'
        - 'POSTGRES_PASSWORD=password'
```

We need our database to be running to run our migrations and get information from it. We also have to define our database URL. 
If you are in kubernetes or docker this is straightforward. If you are developing locally you can use an ```.env``` file. If
this ```.env``` file is in the current working directory all variables will loaded from it for each command. Our ```.env``` file
takes the following form:

```env
DB_URL=postgres://user:password@localhost:5433/admin
```

We can then get information about our migrations state with the following command:

```bash
# with alias
yb db get
# without alias
bash ~/yb_tools/database.sh db get
```

This should return ```-1``` which means that the migration table does not exist therefore we cannot run any migrations. 
To create our migrations table we need to run the command below:

```bash
# with alias
yb db set
# without alias
bash ~/yb_tools/database.sh db set
```

This will create a migration table. The ```get``` will not return a ```0``` which means that the table is made but we are at
migration version zero. We can run a migration as long as we have the environment variable and the ```data_management``` directory
in the current working directory. We can create a run with the following command:

```bash
# with alias
yb db up
# without alias
bash ~/yb_tools/database.sh db up
```

This will apply our migration creating the tables and increasing the version number by one. The ```get``` command will now
return ```1```. We can now create a new migration under the ```2``` directory with the command below:

```bash
# with alias
yb db new
# without alias
bash ~/yb_tools/database.sh db new
```

If we want to move down a migration version in turn dropping the tables we can use the following command:

```bash
# with alias
yb db down
# without alias
bash ~/yb_tools/database.sh db down
```

And with this we have executed all of the commands needed to manage migrations.

### Building an init container

You may want to build an init container for your migrations. You can do this by writing a ```Dockerfile``` right next to your
```.env``` file with the following content:

```Dockerfile
FROM postgres 

RUN apt-get update \
  && apt-get install -y wget \
  && wget -O - https://raw.githubusercontent.com/yellow-bird-consult/build_tools/develop/scripts/install.sh | bash \
  && cp ~/yb_tools/database.sh ./database.sh

WORKDIR .
ADD . .

CMD ["bash", "./database.sh", "db", "rollup"]
```

We can see that we inherit from the ```postgres``` image, install ```wget```, then install our light weight build tools,
and move our ```database.sh``` file into the root directory. We then copy over our ```data_management``` directory with
all of our SQL files and our command entry point is the ```rollup``` which means that the migration is run and then
the container is finished. We must remember to define a ```.dockerignore``` file in the same directory for avoid the
```.env``` file being copied over into the image. We will need to pass environment variables either through docker compose
or Kubernetes so we do not want the ```.env``` file overwriting the variables we pass into the container. Our ```.dockerignore``` file
should take the following form:

```.dockerignore
.env
```

We can now use our image in a docker-compose to run migrations on a local database with the following code:

```yml
init_test_auth_db:
    container_name: init_test
    image: init_test
    build: 
      context: ../database
    environment:
      - 'DB_URL=postgres://username:password@test_postgres:5432/auth'
    depends_on:
        test_postgres:
          condition: service_started
    restart: on-failure
```

Here we tag an image but we point to where our migrations ```Dockerfile``` is the with ```context``` tag. We then pass in the
environment variable of the ```DB_URL``` for the migrations to be applied. We make sure that the database has spun up before
we run our init container. There might be a lag in the database accepting connections so we tell the container to restart
on failure meaning our init container will keep trying until it gets a connection with the database and runs the migration.
