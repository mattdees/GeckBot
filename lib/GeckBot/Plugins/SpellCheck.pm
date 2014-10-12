package GeckBot::Plugins::SpellCheck;

use Text::Aspell;

my $speller = Text::Aspell->new();

$speller->set_option('lang','en_US');

sub triggers {
	return {
		'spellcheck' => \&check,
		'sc' => \&check,
		'wordsuggest' => \&check,
	};
}

sub check {
	my ( $self, $said_hr ) = @_;
	my $word = $said_hr->{'body'};

	my $response;

	if ( $speller->check( $word ) ) {
		$response = '$word is spelled ok';
	}
	else {
		$response = "word is incorrect - " . join( ' ', $speller->suggest( $word ) );
	}

	return $response;
}

1;