package GeckBot::Plugins::SpellCheck;

use Text::Aspell;

my $speller = Text::Aspell->new();

$speller->set_option('lang','en_US');

sub triggers {
	return {
		'spellcheck' => \&check,
		'sc' => \&check,
		'wordsuggest' => \&suggest,
	};
}

sub suggest {
	my ( $self, $said_hr ) = @_;
	my @suggestions = $speller->suggest( $said_hr->{'body'} );
	return "suggestions: " . join( ' ', @suggestions );
}

sub check {
	my ( $self, $said_hr ) = @_;
	my $word = $said_hr->{'body'};
	return $speller->check( $word ) ? "$word is spelled ok" : "$word is not spelled ok";
}

1;