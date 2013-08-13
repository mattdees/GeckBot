package GeckBot::IRC;

use strict;
use warnings;

use Bot::BasicBot;
use parent 'Bot::BasicBot';
use POE;
use Encode 'decode_utf8';

use Symbol;
use Cwd;
use Data::Dumper;

use GeckBot::Logger;

$SIG{CHLD} = sub { wait };

sub init {
	my ( $self ) = @_;

	$self->{actions} = {};
	$self->log('Runing Init');

	if ( !exists $self->{'trigger_prefix'} ) {
		$self->{'trigger_prefix'} = '!';
	}

	if ( !exists $self->{'plugin_base'} ) {
		$self->{'plugin_base'} = cwd;
	}

	$self->{'_loaded_plugins'} = {};

	if ( exists $self->{'plugins'} && ref $self->{'plugins'} eq 'ARRAY' ) {
		foreach my $plugin ( @{ $self->{'plugins'} } ) {
			print "Loading Plugin ${plugin}: ";
			require "GeckBot/Plugins/${plugin}.pm";
			# this is a very weak definition of object..
			my $plugin_obj = qualify("GeckBot::Plugins::${plugin}");
			$plugin_obj->init($self) if $plugin_obj->can('init');
			$self->_build_actions($plugin_obj);
			$self->_build_triggers($plugin_obj);
			$self->_build_ticks($plugin_obj);
			$self->{'_loaded_plugins'}->{$plugin} = undef;
			print "done!\n";
		}
	}

	my $schema = GeckBot::Logger->connect( @{ $self->{'dsn'} } );
	$self->{'schema'} = $schema;
	$self->{'channel_ids'} = _build_channel_id_cache($schema);

	return 1;
}


# Do stuff after we're connected to the server
sub connected {
	my ( $self ) = @_;

	if ( exists $self->{'passworded_channels'} ) {
		foreach my $channel ( keys %{ $self->{'passworded_channels'} } ) {
			my $password = $self->{'passworded_channels'}->{$channel};
			$self->join($channel, $password);
		}
	} 
}


# build a list of actions to be used, this is for generic passing on of 
# subs from Bot::BasicBot
sub _build_actions {
	my ( $self, $plugin_obj ) = @_;
	my @actions = qw/ said emoted noticed chanjoin chanpart chanquit got_names topic nick_change kicked tick connected userquit /;
	foreach my $action ( @actions ) {
		if ( my $code = $plugin_obj->can($action) ) {
			if ( !exists $self->{'actions'}->{$action} ) {
				$self->{'actions'}->{$action} = [];
			}
			$self->log('Adding ' . $plugin_obj . " to $action array " );
			push @{ $self->{'actions'}->{$action} }, $code;
		}
	} 
}


###
# Code to support plugging into the tick() method
#
#
###
sub _build_ticks {
	my ( $self, $plugin_obj ) = @_;
	$self->{'ticks'} = {} if !exists $self->{'ticks'};
	if ( my $tick_cr = $plugin_obj->can('tick') ) {
		$self->{'ticks'}->{$plugin_obj} = {
			'exec' => $tick_cr,
			'next' => 0,
		};
	}
}

# ok, so this one is a bit nuts, on the first tick *all* code will run
# it uses the literal scalar reference string as the key to this hash, so that each object can be associated with
# a time w/o storing any specific information on the object.
#
# The code is expected to return one of two values:
#
# undef - this signifying that this should be run on the next tick
# a unix timestamp of the next time to run the tick

sub tick {
	my ( $self ) = @_;
	return if !exists $self->{'ticks'};
	my $time = time();
	foreach my $enabled_plugin ( keys %{ $self->{'ticks'} } ) {
		#print STDERR Dumper $self->{'ticks'};
		my $tick_cr = $self->{'ticks'}->{$enabled_plugin}->{'exec'};
		my $next_run_time = $self->{'ticks'}->{$enabled_plugin}->{'next'};
		#print STDERR "$next_run_time\n\n";
		if ( $next_run_time == 0 || $next_run_time < $time ) {
			#print Dumper $tick_cr;
			$self->{'ticks'}->{$enabled_plugin}->{'next'} = $tick_cr->($self);
		}
	}
	return 15;
}

###
# Code that supports anything involving "saying" an action.
#
#
###


sub _build_triggers {
	my ( $self, $plugin_obj )  = @_;
	$self->{'triggers'} = {} if !exists $self->{'triggers'}; 
	if ( $plugin_obj->can('triggers') ) {
		my $plugin_triggers = $plugin_obj->triggers;
		foreach my $trigger ( keys %{ $plugin_triggers } ) {
			$self->{'triggers'}->{$trigger} = $plugin_triggers->{$trigger};
		} 
	}
	return;
}

sub said {
	my ( $self, $said_hr ) = @_;

	if ( substr( $said_hr->{'body'}, 0, 1 ) eq $self->{'trigger_prefix'} ) {
		my ( $command, $body ) = split(' ', $said_hr->{'body'}, 2 );
		$command = substr($command, 1);
		if ( exists $self->{'triggers'}->{$command} ) {
			$said_hr->{'body'} = $body;
			return $self->{'triggers'}->{$command}->($self, $said_hr);
		}
	}

	return $self->_run_action( 'said', $said_hr );
}


sub emoted {
	my ( $self, $action_hr ) = @_;
	my $res = $self->_run_action( 'emoted', $action_hr );
	return $res;
}

sub kicked {
	my ( $self, $action_hr ) = @_;
	my $res = $self->_run_action( 'kicked', $action_hr );
	$self->delete_user( $action_hr->{'channel'}, $action_hr->{'kicked'} );
	return $res;
}

sub chanjoin {
	my ( $self, $action_hr ) = @_;
	my $res = $self->_run_action( 'chanjoin', $action_hr );
	$self->add_user( $action_hr->{'channel'}, $action_hr->{'who'} );
	print Dumper $res;
	return $res;
}

sub chanpart {
	my ( $self, $action_hr ) = @_;
	my $res = $self->_run_action( 'chanpart', $action_hr );
	$self->delete_user( $action_hr->{'channel'}, $action_hr->{'who'} );
	return $res;
}

sub userquit {
	my ( $self, $action_hr ) = @_;

	my $user = $action_hr->{'who'};

	foreach my $channel ( keys %{ $self->{_channel_users} } ) {
		if ( exists $self->{_channel_users}->{$channel}->{$user} ) {

			my $chanquit_data = {
				'who' => $user,
				'body' => $action_hr->{'body'},
				'channel' => $channel,
			};

			$self->_run_action( 'chanquit', $chanquit_data );
			$self->delete_user( $channel, $user );
		}
	}
}

sub _run_action {
	my ( $self, $action, $action_data ) = @_;
	
	my @res;
	if ( exists $self->{'actions'}->{$action} ) {
		foreach my $plugin_action ( @{ $self->{'actions'}->{$action} } ) {
			push @res, $plugin_action->( $self, $action_data );
		}
	}

	if ( scalar @res ) {
		return join ' ', @res;
	}
	return;
}

###
# User Management Functions
#
# These functions are used to determine when a user is in a channel
#
# Break these out into another module?
###

sub got_names {
	my ( $self, $name_hr ) = @_;
	my $channel = $name_hr->{'channel'};
	my @user_list = keys %{ $name_hr->{'names'} };
	$self->create_channel_cache( $channel, @user_list );
	return;
}

# create_channel_cache, should be called on got_names()
sub create_channel_cache {
	my ( $self, $channel, @user_list ) = @_;

	$self->{_channel_users} = {} if !exists $self->{_channel_users};
	$self->{_channel_users}->{$channel} = { map { $_ => undef } @user_list };
}

# add user, should be called on join
sub add_user {
	my ( $self, $channel, $user ) = @_;
	$self->{_channel_users}->{$channel}->{$user} = undef;
}

# delete user, should be called on part & quit
sub delete_user {
	my ( $self, $channel, $user ) = @_;
	delete $self->{_channel_users}->{$channel}->{$user};
}

##
# Misc Plugin Utility Functions
##

sub plugin_loaded {
	my ( $self, $plugin ) = @_;
	return exists $self->{'_loaded_plugins'}->{$plugin} ? 1 : 0;
}

###
# SQL-related functions
###

sub _build_channel_id_cache {
	my ( $schema ) = @_;
	my $channel_ref = {};
	my $channels = $schema->resultset('Channel');
	foreach my $channel ($channels->all) {
		print STDERR "Adding " . $channel->name . " to cache\n";
		$channel_ref->{ $channel->name } = $channel->id;
	}
	return $channel_ref;
}


# get the channel id, if it does not exist, create it.
sub get_channel_id {
	my ( $self, $channel ) = @_;
	if ( exists $self->{'channel_ids'}->{ $channel } ) {
		return $self->{'channel_ids'}->{ $channel };
	}
	else {
		return $self->add_channel( $channel);
	}
}

sub add_channel {
	my ( $self, $channel ) = @_;
	my $rs = $self->{'schema'}->resultset('Channel');

	my $result = $rs->create(
		{
			'name' => $channel,
			'network' => $self->{'server'},
		},
	);
	$self->{'channel_ids'}->{$channel} = $result->id;
	return $result->id;
}

sub schema {
	my ( $self ) = @_;
	return $self->{'schema'};
}

# Required to fix issue with UTF-8 decoding the response of forkit() call. Used
# in the callback parameter.
#
# See: Bot::BasicBot <https://rt.cpan.org/Public/Bug/Display.html?id=77459>
sub decode_utf8_and_say {
	my ($self, $channel) = (shift, shift);
	my ($o, $body, $wheel_id) = @_[OBJECT, ARG0, ARG1];
	$self->say(
		body => decode_utf8($body),
		channel => $channel,
	);
	return;
}

1;