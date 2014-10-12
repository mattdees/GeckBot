package GeckBot::Plugins::Help;

use strict;
use warnings;

sub triggers {
	return {
		'help' => \&help,
	};
}

sub help {
	my ( $self ) = @_;
	my @reply;

	return "I know the following commands: " . join(", ", sort keys %{ $self->{'triggers'} } );
}

1;