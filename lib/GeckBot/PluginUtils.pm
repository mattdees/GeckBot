package GeckBot::PluginUtils;

use HTTP::Tiny;
use JSON::XS;
use IO::Socket::SSL;
use Data::Dumper;

=head3 load_tracking( $tracking_dir, $channel )

Load channel specific tracking data

input

=cut

sub load_tracking {
	my ( $tracking_dir, $channel ) = @_;

	$channel =~ s/\#//g;
	my $tracking_file = "${tracking_dir}/${channel}";
	my $tracking_data = { $channel => {} };

	if ( -e $tracking_file ) {
		open my $tracking_fh, '<', $tracking_file;
		my $tracking_string = <$tracking_fh>;
		eval { 
			$tracking_data = JSON::XS::decode_json($tracking_string);
		};
		if ( $@ ) {
			#todo: file-based logging
		}
		close $tracking_fh;
	}

	return $tracking_data;
}

sub save_tracking {
	my ($tracking_dir, $channel, $tracking_data ) = @_;
	$channel =~ s/\#//g;
	my $tracking_file = "${tracking_dir}/${channel}";

	my $tracking_string = JSON::XS::encode_json($tracking_data);

	open my $tracking_fh, '>', $tracking_file;
	print $tracking_fh $tracking_string;
	close $tracking_fh;
}


=head3 shorten_url($url)

Shorten a URL using google's goo.gl service

input: $url - the URL you want to shorten

response - $short_url - the shortened version

=cut

sub shorten_url {
	my ( $url ) = @_;
	my $postdata = encode_json( { 'longUrl' => $url } );

	my $res = HTTP::Tiny->new->post( 'https://www.googleapis.com/urlshortener/v1/url', 
		{ 
			'content' => $postdata,
			'headers' => {
				'Content-Type' => 'application/json',
			},
		},
	);

	if ( $res->{'success'} ) {
		my $data = decode_json( $res->{'content'} );
		return $data->{'id'};
	}
	else {
		print STDERR Dumper $res;
	}
	return;
}
1;