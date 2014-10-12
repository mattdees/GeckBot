package GeckBot::Plugins::Wunderground;

use strict;
use warnings;

use WWW::Wunderground::API;
use Cache::FileCache;

sub triggers {
    return {
        'w'       => \&wunderground,
        'weather' => \&wunderground,
    };
}

sub wunderground {
    my ( $self, $said_hr ) = @_;

    my $location = $said_hr->{'body'};

    my $api_key = $self->{'wunderground_api'}->{'key'};
    my $response;

    my $wun = WWW::Wunderground::API->new(
        location => $location,
        api_key  => $api_key,
        auto_api => 1,
        cache    => Cache::FileCache->new( { namespace => 'wundercache', default_expires_in => 300 } )    #A cache is probably a good idea.
    );

    eval {
    	$response = 'Weather for ' . $wun->conditions->display_location->{full} . ': ' . $wun->conditions->weather . ' ' . $wun->conditions->temperature_string . ' feels: ' . $wun->conditions->feelslike_string . ' wind: ' . $wun->conditions->wind_mph . 'mph ' . $wun->conditions->wind_dir . ' gusts to ' . $wun->conditions->wind_gust_mph . 'mph precip: ' . $wun->conditions->precip_today_string;
    } or do {
        print STDERR 'GeckBot::Plugins::Wunderground $@ - ' . $@;
    };
    return $response;

}

1;
