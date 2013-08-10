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
		return display_quote($self, $channel_id, $key) if defined $key;
	}
	return set_quote($self, $channel_id, $key, $value);
}

sub display_quote {
    my ( $self, $channel_id, $key ) = @_;

    my $quote = get_quote( $self, $channel_id, $key );

    if ( defined $quote ) {
        return "${key}: " . $quote;
    }

    return "$key has no quote set";
}

sub get_quote {
	my ( $self, $channel_id, $key ) = @_;

    my $result = $self->schema->resultset('Quotes')->find(
        {
            'channel_id' => $channel_id,
            'key'        => $key,
        },
    );

    return defined $result ? $result->value : undef;
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

    return "Quote for ${key} updated";
}

sub chanjoin {
    my ( $self, $join_hr ) = @_;
    my $channel_id = $self->get_channel_id( $join_hr->{'channel'} );

    my $who = $join_hr->{'who'};

    my $quote = get_quote( $self, $channel_id, $who );

    if ( defined $quote ) {
        return "\"${quote}\"";
    }
    return;
}

1;