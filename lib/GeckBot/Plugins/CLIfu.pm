package GeckBot::Plugins::CLIfu;

use HTTP::Tiny;
use JSON::XS;

sub triggers {
	my $triggers = {
		'cli' => \&clifu,
	};
	return $triggers;
}

sub clifu {
	my ( $self, $said_hr ) =@_;
	$self->forkit(
		'run' => \&clifu_print,
		'channel' => $said_hr->{'channel'},
		'body' => 'foo',
	);
}

sub clifu_print {
	my $url = "http://www.commandlinefu.com/commands/random/json/";
	my $data = decode_json( HTTP::Tiny->new()->get($url)->{'content'} );

	foreach my $trick ( @{ $data } ) {
		print $trick->{'summary'} . ":\n" . $trick->{'command'} . "\n";
	}

}



1;