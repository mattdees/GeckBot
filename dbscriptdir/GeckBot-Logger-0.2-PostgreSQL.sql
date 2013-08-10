-- 
-- Created by SQL::Translator::Producer::PostgreSQL
-- Created on Sat Aug 10 17:19:58 2013
-- 
--
-- Table: channel_messages.
--
DROP TABLE "channel_messages" CASCADE;
CREATE TABLE "channel_messages" (
  "msg_id" bigserial NOT NULL,
  "sender" character varying(32) NOT NULL,
  "msg" character varying(160) NOT NULL,
  "time" timestamp NOT NULL,
  "channel_id" bigint NOT NULL,
  "type" character varying NOT NULL,
  PRIMARY KEY ("msg_id")
);

--
-- Table: channel_user_events.
--
DROP TABLE "channel_user_events" CASCADE;
CREATE TABLE "channel_user_events" (
  "event_id" bigserial NOT NULL,
  "kicker" character varying(32),
  "who" character varying(32) NOT NULL,
  "reason" character varying(160),
  "time" timestamp NOT NULL,
  "channel_id" bigint NOT NULL,
  "type" character varying NOT NULL,
  PRIMARY KEY ("event_id")
);

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
-- Table: quotes.
--
DROP TABLE "quotes" CASCADE;
CREATE TABLE "quotes" (
  "key" character varying(32) NOT NULL,
  "value" character varying(160) NOT NULL,
  "channel_id" bigint NOT NULL,
  PRIMARY KEY ("channel_id", "key")
);

