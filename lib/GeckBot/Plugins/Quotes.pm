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
            'quote_key'        => $key,
        },
    );

    return defined $result ? $result->value : undef;
}

sub set_quote {
	my ( $self, $channel_id, $key, $value ) = @_;

    # TODO: check if (1) channel is logged, and person said that
    if ( $self->plugin_loaded('Logger') && !check_quote($self, $channel_id, $key, $value) ) {
        return "${key} didn't say that";
    }

    if ( !$key ) {
        return;
    }

	my $quotes = $self->schema->resultset('Channel')->find({ 'id' => $channel_id })
        ->quotes->update_or_new(
        	{ 
        		quote_key => $key,
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

    if ( !exists $self->{'quote_on_join'} || !$self->{'quote_on_join'} ) {
        return;
    }

    my $channel_id = $self->get_channel_id( $join_hr->{'channel'} );
    my $who = $join_hr->{'who'};
    my $quote = get_quote( $self, $channel_id, $who );

    if ( defined $quote ) {
        return "\"${quote}\"";
    }
    return;
}

sub check_quote {
    my ($self , $channel_id, $key, $value) = @_;

    my $schema = $self->{'schema'};

    my $result = $schema->resultset('ChannelMessage')->search(
        {
            'channel_id' => $channel_id,
            'sender' => lc( $key ),
            'msg' => { like => '%'.$value .'%'},
        },
        {
            order_by => { -desc => 'msg_id' },
            rows => 1
        }
    )->single;

    return defined $result ? 1 : 0;
}

1;