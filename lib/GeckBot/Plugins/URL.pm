package GeckBot::Plugins::URL;

use URI::Find;
use HTTP::Tiny;
use HTML::TreeBuilder::XPath;

my $http = HTTP::Tiny->new( 'max_size' => 65536 );

sub said {
	my ( $self, $said_hr ) = @_;
	
	my $body = $said_hr->{'body'};

	my @uris = ();
	my $finder = URI::Find->new(
		sub {
			my($uri) = shift;
			push @uris, $uri;
		}
	);
	$finder->find(\$body);

	foreach my $uri ( @uris ) {
		# I bet you could forkbomb a system using this..
		$self->forkit(
			'run' => \&print_uri_title,
			'channel' => $said_hr->{'channel'},
			'body' => $uri
		);
	}
}

sub print_uri_title {
	my ( $uri ) = @_;
	if ( !defined $uri || $uri eq '' ) {
		return;
	}
	print "[ " . get_uri_title($_[0]) . " ]\n";
}

sub get_uri_title {
	my ($uri ) = @_;

	my $tb = HTML::TreeBuilder::XPath->new();
	my $res = $http->get($uri);
	if ( $res->{'status'} != 200 ) {
		return;
	}
	my $html = $res->{'content'};
	$tb->parse($html);
	my $title = $tb->findvalue('/html/head/title');
	return $title;
}

1;