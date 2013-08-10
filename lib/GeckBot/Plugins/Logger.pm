package GeckBot::Plugins::Logger;

use strict;
use warnings;

use POSIX ('strftime');
use GeckBot::Logger;

sub said {
	my ( $self, $said_hr ) = @_;
	my $schema = $self->{'schema'};
	my $channel_id = $self->get_channel_id( $said_hr->{'channel'} );
	my $msg_add = $schema->resultset('ChannelMessage')->create(
		{
			'sender' => lc( $said_hr->{'who'} ),
			'msg' => $said_hr->{'body'},
			'channel_id' => $channel_id,
			'type' => 'msg',
		},
	);
	return;
}

sub emoted {
	my ( $self, $emoted_hr ) = @_;
	my $schema = $self->{'schema'};
	my $channel_id = $self->get_channel_id( $emoted_hr->{'channel'} );
	my $msg_add = $schema->resultset('ChannelMessage')->create(
		{
			'sender' => lc( $emoted_hr->{'who'} ),
			'msg' => $emoted_hr->{'body'},
			'channel_id' => $channel_id,
			'type' => 'emote',
		},
	);
	return;
}

sub kicked {
	my ( $self, $kicked_hr ) = @_;
	my $schema = $self->{'schema'};
 	my $channel_id = $self->get_channel_id( $kicked_hr->{'channel'} );
	my $msg_add = $schema->resultset('ChannelUserEvents')->create(
		{
			'kicker' => lc( $kicked_hr->{'who'} ),
			'who' => lc( $kicked_hr->{'kicked'} ),
			'reason' => $kicked_hr->{'reason'},
			'channel_id' => $channel_id,
			'type' => 'kick',
		},
	);
	return;
}

sub chanjoin {
	my ( $self, $join_hr  ) = @_;
	my $schema = $self->{'schema'};
 	my $channel_id = $self->get_channel_id( $join_hr->{'channel'} );
	my $msg_add = $schema->resultset('ChannelUserEvents')->create(
		{
			'who' => lc( $join_hr->{'who'} ),
			'channel_id' => $channel_id,
			'type' => 'join',
		},
	);
	return;
}

sub chanpart {
	my ( $self, $part_hr  ) = @_;
	my $schema = $self->{'schema'};
 	my $channel_id = $self->get_channel_id( $part_hr->{'channel'} );
	my $msg_add = $schema->resultset('ChannelUserEvents')->create(
		{
			'who' => lc( $part_hr->{'who'} ),
			'channel_id' => $channel_id,
			'reason' => $part_hr->{'body'},
			'type' => 'part',
		},
	);
	return;
}

sub chanquit {
	my ( $self, $quit_hr  ) = @_;
	my $schema = $self->{'schema'};
 	my $channel_id = $self->get_channel_id( $quit_hr->{'channel'} );
	my $msg_add = $schema->resultset('ChannelUserEvents')->create(
		{
			'who' => lc( $quit_hr->{'who'} ),
			'channel_id' => $channel_id,
			'reason' => $quit_hr->{'body'},
			'type' => 'quit',
		},
	);
	return;
}


sub seen {
	my ( $self, $said_hr ) = @_;
	my $schema = $self->{'schema'};
	my $channel_id = $self->get_channel_id( $said_hr->{'channel'} );

	my $search_user = lc $said_hr->{'body'};

	my $result = $schema->resultset('ChannelMessage')->search(
		{
			'channel_id' => $channel_id,
			'LOWER( me.sender )' => $search_user,
		},
		{
			order_by => { -desc => 'msg_id' },
			rows => 1
		}
	)->single;
	if ( $result ) {
		my $time = strftime( "%a %b %e %H:%M:%S %Y", localtime( $result->time ));
		return $said_hr->{'body'} . ' was last seen at ' . $time. " saying: " . $result->msg;
	}
	else {
		return $said_hr->{'body'} . " has never been seen";
	}
}

sub triggers {
	return {
		'seen' => \&seen,
	};
}




1;