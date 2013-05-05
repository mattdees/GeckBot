package GeckBot::Plugins::Karma;

use strict;
use warnings;

sub said {
	my ( $self, $said_hr ) = @_;
	if ( $said_hr->{'body'} =~ /(.+)(\+\+|\-\-)$/ ) {
		my $key = $1;
		my $operation = $2;
		my $channel_id = $self->get_channel_id( $said_hr->{'channel'} );
		my $value = change_value($self, $operation, $channel_id, $key );
		return "Karma for $key is now " . $value;
	}
	return;
}

sub triggers {
	return {
		'karma' => \&get_karma,
	};
}

sub get_karma {
	my ( $self, $said_hr ) = @_;

	my $key =$said_hr->{'body'};
	my $result = $self->schema->resultset('Karma')->search(
		{
			'channel_id' => $self->get_channel_id( $said_hr->{'channel'} ),
			'key' => $key,
		},
		{
			rows => 1
		}
	)->single;
	if ( defined $result ) {
		return "$key has " . $result->value . " karma";
	}
	return "$key has 0 karma";

}

sub change_value {
	my ( $self, $operation, $channel_id, $key ) = @_;
	my $value;
	my $result = $self->schema->resultset('Karma')->search(
		{
			'channel_id' => $channel_id,
			'key' => $key,
		},
		{
			rows => 1
		}
	)->single;

	if ( !defined $result ) {
		# if the karma entry does not exist
		if ( $operation eq '++' ) {
			$value = 1;
		}
		else {
			$value = -1;
		}

		$self->schema->resultset('Karma')->create(
			{
				'channel_id' => $channel_id,
				'key' => $key,
				'value' => $value,
			}
		);
	}
	else {
		$value = $result->value;
		if ( $operation eq '++' ) {
			$value++;
		}
		else {
			$value--;
		}
		$result->update( {'value' => $value} );
	}
	return $value;
}

1;