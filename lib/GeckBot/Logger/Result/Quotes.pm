package GeckBot::Logger::Result::Quotes;

use strict;
use warnings;

use base qw/DBIx::Class::Core/;

__PACKAGE__->table('quotes');

__PACKAGE__->add_columns(
    key => {
        data_type   => 'VARCHAR',
        size        => 32,
        is_nullable => 0,
    },
    value => {
        data_type   => 'VARCHAR',
        size        => 160,
        is_nullable => 0,
    },
    channel_id => {
        data_type   => 'INT',
        size        => 16,
        is_nullable => 0,
    }
);

__PACKAGE__->set_primary_key(qw(channel_id key));

1;