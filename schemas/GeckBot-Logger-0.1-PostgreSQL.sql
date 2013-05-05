-- 
-- Created by SQL::Translator::Producer::PostgreSQL
-- Created on Sun May  5 13:15:02 2013
-- 
--
-- Table: channels.
--
DROP TABLE "channels" CASCADE;
CREATE TABLE "channels" (
  "id" bigserial NOT NULL,
  "name" character varying(32) NOT NULL,
  "network" character varying(64) NOT NULL,
  PRIMARY KEY ("id")
);

--
-- Table: karma.
--
DROP TABLE "karma" CASCADE;
CREATE TABLE "karma" (
  "key" character varying(32) NOT NULL,
  "value" bigint NOT NULL,
  "channel_id" bigint NOT NULL,
  PRIMARY KEY ("channel_id", "key")
);

--
-- Table: msgs.
--
DROP TABLE "msgs" CASCADE;
CREATE TABLE "msgs" (
  "msg_id" bigserial NOT NULL,
  "sender" character varying(32) NOT NULL,
  "msg" character varying(160) NOT NULL,
  "time" bigint NOT NULL,
  "channel_id" bigint NOT NULL,
  PRIMARY KEY ("msg_id")
);

