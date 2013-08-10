-- 
-- Created by SQL::Translator::Producer::SQLite
-- Created on Sat Aug 10 17:19:58 2013
-- 

BEGIN TRANSACTION;

--
-- Table: channel_messages
--
DROP TABLE channel_messages;

CREATE TABLE channel_messages (
  msg_id INTEGER PRIMARY KEY NOT NULL,
  sender VARCHAR(32) NOT NULL,
  msg VARCHAR(160) NOT NULL,
  time datetime NOT NULL,
  channel_id INT(16) NOT NULL,
  type enum NOT NULL
);

--
-- Table: channel_user_events
--
DROP TABLE channel_user_events;

CREATE TABLE channel_user_events (
  event_id INTEGER PRIMARY KEY NOT NULL,
  kicker VARCHAR(32),
  who VARCHAR(32) NOT NULL,
  reason VARCHAR(160),
  time datetime NOT NULL,
  channel_id INT(16) NOT NULL,
  type enum NOT NULL
);

--
-- Table: channels
--
DROP TABLE channels;

CREATE TABLE channels (
  id INTEGER PRIMARY KEY NOT NULL,
  name VARCHAR(32) NOT NULL,
  network VARCHAR(64) NOT NULL
);

--
-- Table: karma
--
DROP TABLE karma;

CREATE TABLE karma (
  key VARCHAR(32) NOT NULL,
  value INT(16) NOT NULL,
  channel_id INT(16) NOT NULL,
  PRIMARY KEY (channel_id, key)
);

--
-- Table: quotes
--
DROP TABLE quotes;

CREATE TABLE quotes (
  key VARCHAR(32) NOT NULL,
  value VARCHAR(160) NOT NULL,
  channel_id INT(16) NOT NULL,
  PRIMARY KEY (channel_id, key)
);

COMMIT;
