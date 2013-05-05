package GeckBot::Logger::Result::ChannelMessage;

use strict;
use warnings;

use base qw/DBIx::Class::Core/;

__PACKAGE__->table('msgs');

__PACKAGE__->add_columns(
	msg_id => {
		data_type => 'integer',
		size => 256,
		is_nullable => 0,
		is_auto_increment => 1,
	},
	sender => {
		data_type => 'varchar',
		size => 32,
		is_nullable => 0,
	},
	msg => {
		data_type => 'varchar',
		size => 160,
		is_nullable => 0,
	},
	time => {
		data_type => 'int',
		size => 16,
		is_nullable => 0,
	},
	channel_id => {
		data_type => 'int',
		size => 16,
		is_nullable => 0,
	}
);

__PACKAGE__->set_primary_key('msg_id');


1;