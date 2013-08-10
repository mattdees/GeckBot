#!/usr/bin/env perl

use lib 'lib';

use GeckBot::Logger;

my $dsn = '';

my $schema = GeckBot::Logger->connect($dsn);
$schema->create_ddl_dir(['MySQL', 'SQLite', 'PostgreSQL'],
	'0.2',
	'./dbscriptdir/'
);
