package GeckBot::Logger::Result::Karma;

use base qw/DBIx::Class::Core/;

__PACKAGE__->table('karma');

__PACKAGE__->add_columns(
	karma_id => {
		data_type => 'integer',
		size => 256,
		is_nullable => 0,
		is_auto_increment => 1,
	},
	key => {
		data_type => 'varchar',
		size => 32,
		is_nullable => 0,
	},
	value => {
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

__PACKAGE__->set_primary_key('karma_id');


1;