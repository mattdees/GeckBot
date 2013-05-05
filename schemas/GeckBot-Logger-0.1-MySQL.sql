-- 
-- Created by SQL::Translator::Producer::MySQL
-- Created on Sun May  5 01:38:22 2013
-- 
SET foreign_key_checks=0;

DROP TABLE IF EXISTS `channels`;

--
-- Table: `channels`
--
CREATE TABLE `channels` (
  `id` integer(256) NOT NULL auto_increment,
  `name` varchar(32) NOT NULL,
  `network` varchar(64) NOT NULL,
  PRIMARY KEY (`id`)
);

DROP TABLE IF EXISTS `karma`;

--
-- Table: `karma`
--
CREATE TABLE `karma` (
  `karma_id` integer(256) NOT NULL auto_increment,
  `key` varchar(32) NOT NULL,
  `value` integer(16) NOT NULL,
  `channel_id` integer(16) NOT NULL,
  PRIMARY KEY (`karma_id`)
);

DROP TABLE IF EXISTS `msgs`;

--
-- Table: `msgs`
--
CREATE TABLE `msgs` (
  `msg_id` integer(256) NOT NULL auto_increment,
  `sender` varchar(32) NOT NULL,
  `msg` varchar(160) NOT NULL,
  `time` integer(16) NOT NULL,
  `channel_id` integer(16) NOT NULL,
  PRIMARY KEY (`msg_id`)
);

SET foreign_key_checks=1;

