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
			print "done!\n";
		}
	}

	my $schema = GeckBot::Logger->connect( @{ $self->{'dsn'} } );
	$self->{'schema'} = $schema;
	$self->{'channel_ids'} = _build_channel_id_cache($schema);

	return 1;
}



# build a list of actions to be used, this is for generic passing on of 
# subs from Bot::BasicBot
sub _build_actions {
	my ( $self, $plugin_obj ) = @_;
	my @actions = qw/ said emoted noticed chanjoin chanpart got_names topic nick_change kicked tick connected userquit /;
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
		print STDERR "$next_run_time\n\n";
		if ( $next_run_time == 0 || $next_run_time > $time ) {
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

	my $action = 'said';
	my @res;
	if ( exists $self->{'actions'}->{$action} ) {
		foreach my $plugin_action ( @{ $self->{'actions'}->{$action} } ) {
			push @res, $plugin_action->(@_);
		}
	}
	return join( ' ', @res );
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