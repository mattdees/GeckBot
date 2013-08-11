package GeckBot::Plugins::RSS;

use strict;
use warnings;

use HTTP::Tiny;
use XML::RSS::LibXML;
use Date::Parse 'str2time';

use GeckBot::PluginUtils;

sub tick {
	my ( $self ) = @_;
	
	foreach my $channel ( @{ $self->{ 'rss_channels' } } ) {
		my $channel_id = $self->get_channel_id($channel);
		my $feeds_hr = $self->{'rss_config'}->{$channel};
		$self->forkit(
			'run' => \&check_rss,
			'channel' => $channel,
			'body' => $channel_id,
			'arguments' => [ $self->schema ],
		);
	}

	return time + 120;
}

sub check_rss {
	my ( $channel_id, $schema ) = @_;

	my $rss_list = $schema->resultset('RSS')->search({ 'channel_id' => $channel_id });

	return if !defined $rss_list; #return if nothing is found

	while ( my $rss_db = $rss_list->next ) {
		my $feed_data = get_feed( $rss_db->url );
		my $first_post_time = str2time( $feed_data->{'items'}->[0]->{'pubDate'} );

		# skip the rest if they match
		if ( $first_post_time == $rss_db->last_post ) {
			last;
		}

		# loop over until we hit MAX.
		foreach my $post ( @{ $feed_data->{'items'} } ) {
			my $unix_date = str2time( $post->{'pubDate'} );
			if ( $unix_date <= $rss_db->last_post ) {
				last;
			}
			my $short_link = GeckBot::PluginUtils::shorten_url( $post->{'link'} );
			print $short_link . ' - ' . $post->{'title'} . "\n";
		}

		$rss_db->update( { last_post => $first_post_time } );
	}
}

sub get_feed {
	my ( $url ) = @_;

	my $rss = XML::RSS::LibXML->new;
	my $feed = HTTP::Tiny->new->get( $url );
	if ( $feed->{'success'} ) {
		my $data = $rss->parse( $feed->{'content' });
		return $data;		
	}
	print STDERR 'Error while parsing RSS Feed: ' . $url;
}



1;