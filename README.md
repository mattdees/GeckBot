GeckBot
=======

GeckBotIRC

An IRC bot designed to be pluggable, scalable and do what I want to it to.

Mostly it's used for me to experiment with new programming paradigms, however it is stable and has a few instances out there running.

Installation
=======
It's not that complicated however I really don't want to document all of it. I'll put a Dockerfile out eventually.

To create the necessary database schemas, run the following:
> perl create_schemas.pl

This will export sqlite files that you will put into a database and  add the dsn for that DB to <botname>.pl file to give GeckBot a SQL backend.
