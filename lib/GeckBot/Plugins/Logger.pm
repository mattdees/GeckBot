package GeckBot::Plugins::Logger;

use POSIX ('strftime');
use GeckBot::Logger;

sub said {
	my ( $self, $said_hr ) = @_;
	my $schema = $self->{'schema'};
	my $channel_id = $self->get_channel_id( $said_hr->{'channel'} );

	my $msg_add = $schema->resultset('ChannelMessage')->create(
		{
			'sender' => $said_hr->{'who'},
			'msg' => $said_hr->{'body'},
			'time' => time(),
			'channel_id' => $channel_id,
		},
	);
	return;
}

sub seen {
	my ( $self, $said_hr ) = @_;
	my $schema = $self->{'schema'};
	my $channel_id = $self->get_channel_id( $said_hr->{'channel'} );

	my $result = $schema->resultset('ChannelMessage')->search(
		{
			'channel_id' => $channel_id,
			'sender' => $said_hr->{'body'},
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