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
