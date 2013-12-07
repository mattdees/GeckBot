package GeckBot::Logger::Result::Karma;

use strict;
use warnings;

use base qw/DBIx::Class::Core/;

sub new
{
    my ($class, $attrs) = @_;
    $attrs->{value} = 0 unless defined $attrs->{value};
    my $new = $class->next::method($attrs);
    return $new;
}

__PACKAGE__->table('karma');

__PACKAGE__->add_columns(
    karma_key => {
        data_type   => 'VARCHAR',
        size        => 32,
        is_nullable => 0,
    },
    value => {
        data_type   => 'INT',
        size        => 16,
        is_nullable => 0,
    },
    channel_id => {
        data_type   => 'INT',
        size        => 16,
        is_nullable => 0,
    }
);

__PACKAGE__->set_primary_key(qw(channel_id karma_key));

1;
