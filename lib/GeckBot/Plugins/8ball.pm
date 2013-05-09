package GeckBot::Plugins::8ball;


sub init {
	my ( $sym, $self ) = @_;
	$self->{'8ball'}->{'strings'} = [];

	open my $eightball_fh, '<', $self->{'plugin_base'} . '/etc/8ball.strings';
	my $count = 0;
	while ( my $line = readline $eightball_fh ) {
		chomp $line;
		push @{ $self->{'8ball'}->{'strings'} }, $line;
		$count++;
	}
	close $eightball_fh;
	$self->{'8ball'}->{'size'} = $count;
}

sub eightball {
	my ( $self, $said_hr ) = @_;
	if ( $said_hr->{'body'} =~ /freshkippers/ ) {
		return "Because freshkippers smells like crack and hooker spit";
	}
	my $selection = int rand( $self->{'8ball'}->{'size'} );
	return $self->{'8ball'}->{'strings'}->[$selection];
}

sub triggers {
	my $triggers = {
		'8ball' => \&eightball,
	};
	return $triggers;
}


1;
