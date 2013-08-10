-- 
-- Created by SQL::Translator::Producer::MySQL
-- Created on Sat Aug 10 17:19:58 2013
-- 
SET foreign_key_checks=0;

DROP TABLE IF EXISTS `channel_messages`;

--
-- Table: `channel_messages`
--
CREATE TABLE `channel_messages` (
  `msg_id` integer(32) NOT NULL auto_increment,
  `sender` VARCHAR(32) NOT NULL,
  `msg` VARCHAR(160) NOT NULL,
  `time` datetime NOT NULL,
  `channel_id` integer(16) NOT NULL,
  `type` enum('msg', 'emote', 'notice') NOT NULL,
  PRIMARY KEY (`msg_id`)
);

DROP TABLE IF EXISTS `channel_user_events`;

--
-- Table: `channel_user_events`
--
CREATE TABLE `channel_user_events` (
  `event_id` integer(32) NOT NULL auto_increment,
  `kicker` VARCHAR(32) NULL,
  `who` VARCHAR(32) NOT NULL,
  `reason` VARCHAR(160) NULL,
  `time` datetime NOT NULL,
  `channel_id` integer(16) NOT NULL,
  `type` enum('join', 'part', 'kick', 'quit') NOT NULL,
  PRIMARY KEY (`event_id`)
);

DROP TABLE IF EXISTS `channels`;

--
-- Table: `channels`
--
CREATE TABLE `channels` (
  `id` integer(32) NOT NULL auto_increment,
  `name` VARCHAR(32) NOT NULL,
  `network` VARCHAR(64) NOT NULL,
  PRIMARY KEY (`id`)
);

DROP TABLE IF EXISTS `karma`;

--
-- Table: `karma`
--
CREATE TABLE `karma` (
  `key` VARCHAR(32) NOT NULL,
  `value` integer(16) NOT NULL,
  `channel_id` integer(16) NOT NULL,
  PRIMARY KEY (`channel_id`, `key`)
);

DROP TABLE IF EXISTS `quotes`;

--
-- Table: `quotes`
--
CREATE TABLE `quotes` (
  `key` VARCHAR(32) NOT NULL,
  `value` VARCHAR(160) NOT NULL,
  `channel_id` integer(16) NOT NULL,
  PRIMARY KEY (`channel_id`, `key`)
);

SET foreign_key_checks=1;

