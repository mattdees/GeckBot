package GeckBot::Plugins::Roulette;

use strict;
use warnings;

sub init {
	my ( $sym, $self ) = @_;
	$self->{'roulette_session'} = {};
}

sub triggers {
	return {
		'roulette' => \&roulette,
	};
}

sub roulette {
	my ( $self, $said_hr ) = @_;
	my $channel = $said_hr->{'channel'};
	my $nick = $said_hr->{'who'};

	if ( exists $self->{'roulette_session'}->{$channel} ) {
		$self->say(
			'body' => "${nick} pulled the triggers... click",
			'channel' => $channel,
		);
		if ( int rand( 6 ) == 0 ) {
			$self->kick($channel, $nick, 'BANG');
			delete $self->{'roulette_session'}->{$channel};
		}
	}
	else {
		$self->{'roulette_session'}->{$channel} = 1;
		return "$nick has started a game of roulette type !roulette in order to pull the trigger";
	}
	return undef;
}

1;
