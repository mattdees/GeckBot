package GeckBot::Plugins::Quotes;

use strict;
use warnings;

use GeckBot::Logger;

sub triggers
{
    return { 'quote' => \&quote, };
}

sub quote {
	my ( $self, $said_hr) = @_;
	my $body = $said_hr->{'body'};

	my $channel_id = $self->get_channel_id( $said_hr->{'channel'} );

	my ( $key, $value ) = split( ' ', $body, 2);
	if ( !defined $value ) {
		return get_quote($self, $channel_id, $key) if defined $key;
	}
	return set_quote($self, $channel_id, $key, $value);
}

sub get_quote {
	my ( $self, $channel_id, $key ) = @_;

    my $result = $self->schema->resultset('Karma')->find(
        {
            'channel_id' => $channel_id,
            'key'        => $key,
        },
    );

    if ( defined $result ) {
    	return "${key}: " . $result->value;
    }
    return "$key has no quote set for it";
}

sub set_quote {
	my ( $self, $channel_id, $key, $value ) = @_;

	my $quotes = $self->schema->resultset('Channel')->find({ 'id' => $channel_id })
        ->quotes->update_or_new(
        	{ 
        		key => $key,
        		value => $value,
        	}
        );

    if ( !$quotes->in_storage ) {
    	$quotes->insert;
    }

    return "Quote for ${key} is updated";
}

1;