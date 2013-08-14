package GeckBot::Plugins::Twitter;

use strict;
use warnings;

use Net::Twitter;
use GeckBot::PluginUtils ('load_tracking', 'save_tracking' );

my $tracking_dir = 'var/twitter';

my $firstrun = 1;

sub init {
	my ( $sym, $self ) = @_;

	$self->{_twitter_api} = {};

	foreach my $channel ( keys %{ $self->{'twitter_creds'} } ) {
		my %twitter_args = %{ $self->{'twitter_creds'}->{$channel} };
		$twitter_args{'traits'} = [qw/API::RESTv1_1/];
		$self->{_twitter_api}->{$channel} = Net::Twitter->new( %twitter_args );
	}

	mkdir $tracking_dir if !-d $tracking_dir;
}

sub tick {
	my ( $self ) = @_;
	print "running twitter bot: " . time . "\n";
	foreach my $channel ( keys %{ $self->{'twitter_creds'} } ) {
		my $twitter_api = $self->{'_twitter_api'}->{$channel};
		$self->forkit(
			'run' => \&check_twitter,
			'channel' => $channel,
			'body' => $twitter_api,
			'arguments' => [$channel, $firstrun],
		);
	}
	$firstrun = 0;
	return time + 120;
}

sub check_twitter {
	my ( $twitter_api, $channel, $firstrun ) = @_;

	my $tracking_data = GeckBot::PluginUtils::load_tracking($tracking_dir, $channel) || {};
	my $last_id = $tracking_data->{'last_id'} // 0;
	my $feed;
	
	eval {
		$feed = $twitter_api->home_timeline;		
	};
	if ( $@ ) {
		print STDERR "Could not populate feed!!!\n";;
		exit;
	}

	my $first_id = $feed->[0]->{id};
	if ( $last_id eq $first_id ) {
		# if the last_id is the top of the feed, just exit
		exit;
	}

	GeckBot::PluginUtils::save_tracking( $tracking_dir, $channel, { last_id => $first_id } );
	exit if $firstrun; # do not display posts if this is the first run

	foreach my $post ( @{ $feed } ) {
		last if $post->{'id'} <= $last_id;
		print '@' .$post->{user}->{screen_name} . ': ' .  $post->{text} . "\n";
	}
}

sub follow {
	my ( $self, $said_hr ) = @_;
	my $channel = $said_hr->{'channel'};
	my $screen_name = $said_hr->{'body'};
	$screen_name =~ s/\s//g;	# remove whitespace
	eval {
		$self->{'_twitter_api'}->{$channel}->create_friend( $screen_name );
	};
	if ( $@ ) {
		return "Unable to follow ${screen_name}: " . $@->error;
	}
	return "Now following ${screen_name}";
}

sub unfollow {
	my ( $self, $said_hr ) = @_;
	my $channel = $said_hr->{'channel'};
	my $screen_name = $said_hr->{'body'};
	$screen_name =~ s/\s//g;	# remove whitespace
	eval {
		$self->{'_twitter_api'}->{$channel}->destroy_friend($screen_name);
	};
	if ( $@ ) {
		return "Unable to unfollow $screen_name: " . $@->error;
	}
	return "No longer folowing $screen_name";
}

sub gettweet {
	my ( $self, $said_hr ) = @_;

	my $channel = $said_hr->{channel};
	my ( $resource, $index ) = split( /\s/, $said_hr->{'body'}, 2);
	$index = 1 if !defined $index;
	$index--;

	my $msg;
	eval {
			my $res = $self->{'_twitter_api'}->{$channel}->user_timeline( { 'screen_name' => $resource } );
			my $tweet = $res->[$index];
			$msg = '@' . $tweet->{'user'}->{'screen_name'} . ': ' . $tweet->{'text'};
	};
	if ( $@ ) {
		return $@->error if ref $@;
		return "Could not grab tweet for $resource";
	}
	return $msg;
}

sub triggers {
	return {
		'follow' => \&follow,
		'unfollow' => \&unfollow,
		'gettweet' => \&gettweet,
		'gt' => \&gettweet,
	};
}

1;
