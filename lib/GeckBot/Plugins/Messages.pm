package GeckBot::Plugins::Messages;

use strict;
use warnings;

# Where your messages will go.  Put them into a file called #${channel_name}.msg
# If you want 'BOO' to go into #yourircroom:
# $(echo 'BOO' > ${cachedir}/yourircroom.msg)
my $cachedir = ".msg_cache";


sub tick {
    my ( $self ) = @_;

    my @msgs =  sort { -M $b <=> -M $a } grep { -f } glob("$cachedir/*.msg");

    if (@msgs) {
        foreach my $file (@msgs) {
            my $channel = '#' . $1 if $file =~ /.*\/(\w+).msg/;
            open(FILE, "$file");
            while(<FILE>) {
                $self->say( 'body' => "$_", 'channel' => $channel );    
            }
            close(FILE);
            unlink("$file");
        }
    }

    return time + 3;

}    

1;
