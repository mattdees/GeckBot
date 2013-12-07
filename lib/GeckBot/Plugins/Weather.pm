package GeckBot::Plugins::Weather;

use strict;
use warnings;

use HTTP::Tiny 	();
use JSON;

sub triggers {
    return { 
    	'w' => \&wunderground,
    	'weather' => \&wunderground,
    };
}

sub wunderground {
    my ($self, $said_hr) = @_;

    my $zip_code =  $said_hr->{'body'};

    if ( $zip_code !~ /^[A-Z0-9-]{3,10}$/) {
    	return "Invalid zipcode: $zip_code";
    }

    my $api_key = $self->{'wunderground_api'}->{'key'};

    my $response = 'Unknown Error Occurred';
    eval {
   	 	my $res = HTTP::Tiny->new->get("http://api.wunderground.com/api/${api_key}/conditions/q/${zip_code}.json");
   	 	#TODO: actually handle errors
   	 	my $data = decode_json( $res->{'content'} );
   	 	my $current = $data->{'current_observation'};
   	 	$response = 'Weather for ' . 
   	 	$current->{'display_location'}->{'full'} . ': ' . $current->{'weather'} . ' ' .
   	 	$current->{'temperature_string'} . 
   	 	' feels: ' . $current->{'feelslike_string'} . 
   	 	' wind: ' . $current->{'wind_mph'} . 'mph '  . $current->{'wind_dir'} . ' gusts to ' . $current->{'wind_gust_mph'} . 'mph ' .
   	 	' precip: ' . $current->{'precip_today_string'};
	};
	if ( $@ ) {
		print STDERR "exception caught while retrieving weather data. \n\n" . $@ . "\n\n";
	}

	return $response;


}

1;