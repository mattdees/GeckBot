package GeckBot::Plugins::TickTest;

sub tick {
	my ( $self ) = @_;
	
	foreach my $channel ( keys %{ $self->{'reddit_config'} } ) {
		my $subreddit = $self->{'reddit_config'}->{$channel};
		
		$self->forkit(
			'run' => \&ticktest,
			'channel' => $channel,
			'body' => $subreddit,
			'arguments' => [$channel],
		);
	}
	return time + 30;	
}

sub ticktest {
	print time() . ' ' . join( ' ', @_ ) . "\n";
}

1;