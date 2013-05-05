package GeckBot::Logger::Result::Karma;

use base qw/DBIx::Class::Core/;


sub new {
	my ( $class, $attrs ) = @_;
	$attrs->{value} = 0 unless defined $attrs->{value};
	my $new = $class->next::method($attrs);
	return $new;
}


__PACKAGE__->table('karma');

__PACKAGE__->add_columns(
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

__PACKAGE__->set_primary_key(qw(channel_id key));


1;