-- 
-- Created by SQL::Translator::Producer::SQLite
-- Created on Sun May  5 01:38:22 2013
-- 

BEGIN TRANSACTION;

--
-- Table: channels
--
DROP TABLE channels;

CREATE TABLE channels (
  id INTEGER PRIMARY KEY NOT NULL,
  name varchar(32) NOT NULL,
  network varchar(64) NOT NULL
);

--
-- Table: karma
--
DROP TABLE karma;

CREATE TABLE karma (
  karma_id INTEGER PRIMARY KEY NOT NULL,
  key varchar(32) NOT NULL,
  value int(16) NOT NULL,
  channel_id int(16) NOT NULL
);

--
-- Table: msgs
--
DROP TABLE msgs;

CREATE TABLE msgs (
  msg_id INTEGER PRIMARY KEY NOT NULL,
  sender varchar(32) NOT NULL,
  msg varchar(160) NOT NULL,
  time int(16) NOT NULL,
  channel_id int(16) NOT NULL
);

COMMIT;
