package GeckBot::Plugins::Karma;

use strict;
use warnings;

sub said
{
    my ($self, $said_hr) = @_;
    if ($said_hr->{'body'} =~ /(.+)(\+\+|\-\-)$/) {
        my $key       = $1;
        my $operation = $2;

        if ($key =~ /^(?:.+\ ){2,}.+$/) {
            # if the string has more than two spaces...
            return;
        }
        $key =~ s/^\W*(\w+)\W*$/$1/g;
        my $channel_id = $self->get_channel_id($said_hr->{'channel'});
        my $value = change_value($self, $operation, $channel_id, $key, 1);
        return "Karma for $key is now " . $value;
    }
    return;
}

sub triggers
{
    return { 'karma' => \&get_karma, };
}

sub get_karma
{
    my ($self, $said_hr) = @_;

    my ( $key, $operation ) = split /\s/, $said_hr->{'body'}, 2;

    my $channel_id = $self->get_channel_id($said_hr->{'channel'});
    my $value;

    if ( defined $operation && $operation =~ /\s*\+\s*(\d+)/) {
        $value = change_value($self, '++', $channel_id, $key, $1);
    }
    elsif ( defined $operation && $operation =~ /\s*\-\s*(\d+)/) {
        $value = change_value($self, --, $channel_id, $key, $1);
    }
    else {
        my $result = $self->schema->resultset('Karma')->find(
            {
                'channel_id' => $channel_id,
                'key'        => $key,
            },
        );
        $value = defined $result ? $result->value : 0;
    }

    return "$key has $value karma";

}

sub change_value
{
    my ($self, $operation, $channel_id, $key, $value) = @_;
    my $value;
    my $karma =
      $self->schema->resultset('Channel')->find({ 'id' => $channel_id })
      ->karma->find_or_new({ key => $key });
    if ($operation eq '++') {
        $karma->value($karma->value + $value);
    }
    else {
        $karma->value($karma->value - $value);
    }
    $karma->insert_or_update;
    return $karma->value;
}

1;
