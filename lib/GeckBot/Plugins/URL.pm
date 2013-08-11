package GeckBot::Plugins::URL;

use Data::Dumper;
use URI::Find;
use IO::Socket::SSL;
use HTTP::Tiny;
use HTML::TreeBuilder::XPath;
use HTML::Entities 'decode_entities';
use GeckBot::PluginUtils 'shorten_url';
use Data::Structure::Util;

my $http = HTTP::Tiny->new( 'max_size' => 1048576 );

sub said {
	my ( $self, $said_hr ) = @_;
	
	my $body = $said_hr->{'body'};

	my @uris = ();

	if ( $body =~ /spotify:([A-z0-9:]+)/ ) {
		 my @data = split(':', $1);
		 push @uris, 'http://open.spotify.com/' . join('/', @data);
	}
	else {
		my $finder = URI::Find->new(
			sub {
				my($uri) = shift;
				push @uris, $uri->as_string;
			}
		);
		$finder->find(\$body);
	}

	foreach my $uri ( @uris ) {
		# I bet you could forkbomb a system using this..
		$self->forkit(
			'run' => \&print_uri_title,
			'channel' => $said_hr->{'channel'},
			'body' => $uri,
			callback => sub { $self->decode_utf8_and_say($said_hr->{channel}, @_) },
		);
	}
}

sub print_uri_title {
	my ( $uri ) = @_;
	my $title = get_uri_title($uri);
	if ( !$title ) {
		return;
	}
	$title = substr $title, 0, 140;
	my $res = decode_entities( $title );

	my $short_url = GeckBot::PluginUtils::shorten_url( $uri );

	if ( defined $short_url ) {
		$res = "$short_url - $res";
	}
	else {
		$res = "[ $res ]";
	}
	
	print $res . "\n";
#	print "[ " . decode_entities( $title ) . " ]\n";
}

sub get_uri_title {
	my ($uri ) = @_;

	my $tb = HTML::TreeBuilder::XPath->new();
	my $res = $http->get($uri);
	
	if ( $res->{'status'} != 200 ) {
		return 0;
	}
	
	my $html = $res->{'content'};
	$tb->parse($html);
	
	if (!$tb->exists('/html/head/title') ) {
		return 0;
	}

	my $title = $tb->findvalue('/html/head/title');
	if ( !$title ) {
		return 0;
	}
	return $title;
}

1;