CREATE TABLE usersfive (
    id SERIAL NOT NULL PRIMARY KEY,
    username varchar(80) NOT NULL UNIQUE,
    email varchar(120) UNIQUE
);


CREATE TABLE user_institutionfive (
    id SERIAL NOT NULL PRIMARY KEY,
    user_id integer,
    institution_id integer
);