package GeckBot::Logger::Result::ChannelMessage;

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

__PACKAGE__->table('channel_messages');

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
            list => [qw/msg emote notice/]
        },
	}
);

__PACKAGE__->set_primary_key('msg_id');


1;