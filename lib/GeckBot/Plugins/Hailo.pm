package GeckBot::Plugins::Hailo;

use Data::Dumper;

use Hailo;

my $hailo = Hailo->new(
	'brain' => 'geckbot.brn',
);
my $learnall = 1;

my %ignore_nicks = (
	'clutchbot' => 1,
);
sub said {
	my ( $self, $said_hr ) = @_;
	
	return if exists $ignore_nicks{ $said_hr->{'who'} };

	my $body = $said_hr->{'raw_body'};
	my $nick = $self->{'nick'};


	my $triggered = 0;

	if ( $body =~ /$nick/ ) {
		$triggered = 1;
		$body =~ s/^$nick[:, ]*//;

		$hailo->learn($body);
		$hailo->save();
		return $hailo->reply($body);		
	}
	elsif ( $learnall ) {

		$hailo->learn($body);
	}
}

1;