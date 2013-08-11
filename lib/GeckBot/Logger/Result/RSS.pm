package GeckBot::Logger::Result::RSS;

use strict;
use warnings;

use base qw/DBIx::Class::Core/;

__PACKAGE__->table('rss_feeds');

__PACKAGE__->add_columns(
	rss_id => {
		data_type => 'INT',
		size => 32,
		is_nullable => 0,
		is_auto_increment => 1,
	},
	url => {
		data_type => 'VARCHAR',
		size => 255,
		is_nullable => 0,
	},
	last_post => { #unixtime!
		data_type => 'INT',
		size => 16,
		is_nullable => 0,
	},
	channel_id => {
		data_type => 'INT',
		size => 16,
		is_nullable => 0,
	},
	title => {
        data_type => 'VARCHAR',
	    size => 32,
	    is_nullable => 0,
	},
);

__PACKAGE__->set_primary_key('rss_id');


1;