package GeckBot::Logger::Result::ChannelMessage;

use strict;
use warnings;

use base qw/DBIx::Class::Core/;

__PACKAGE__->table('msgs');

__PACKAGE__->add_columns(
	msg_id => {
		data_type => 'INT',
		size => 32,
		is_nullable => 0,
		is_auto_increment => 1,
	},
	sender => {
		data_type => 'VARCHAR',
		size => 32,
		is_nullable => 0,
	},
	msg => {
		data_type => 'VARCHAR',
		size => 160,
		is_nullable => 0,
	},
	time => {
		data_type => 'INT',
		size => 16,
		is_nullable => 0,
	},
	channel_id => {
		data_type => 'INT',
		size => 16,
		is_nullable => 0,
	}
);

__PACKAGE__->set_primary_key('msg_id');


1;