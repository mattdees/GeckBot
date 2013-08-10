package GeckBot::Logger::Result::ChannelUserEvents;

use strict;
use warnings;

use DateTime;
use base qw/DBIx::Class::Core/;

sub new
{
    my ($class, $attrs) = @_;
    $attrs->{time} = DateTime->now() unless defined $attrs->{value};
    my $new = $class->next::method($attrs);
    return $new;
}

__PACKAGE__->load_components(qw/InflateColumn::DateTime/);

__PACKAGE__->table('channel_user_events');

__PACKAGE__->add_columns(
	event_id => {
		data_type => 'INT',
		size => 32,
		is_nullable => 0,
		is_auto_increment => 1,
	},
	kicker => {
		data_type => 'VARCHAR',
		size => 32,
		is_nullable => 1,
	},
	who => {
		data_type => 'VARCHAR',
		size => 32,
		is_nullable => 0,
	},
	reason => {
		data_type => 'VARCHAR',
		size => 160,
		is_nullable => 1,
	},
	time => {
		data_type => 'datetime',
	},
	channel_id => {
		data_type => 'INT',
		size => 16,
		is_nullable => 0,
	},
	type => {
        data_type => 'enum',
	    is_enum => 1,
        extra => {
            list => [qw/join part kick quit/]
        },
	}
);

__PACKAGE__->set_primary_key('event_id');


1;