package Dist::Iller::Builder;

# VERSION

use strict;
use warnings;
use Path::Tiny;
use Types::Standard 'Any';
use YAML::Tiny;
use Moose;

has yaml => (
    is => 'ro',
    isa => Any,
);

around BUILDARGS => sub {
    my $orig = shift;
    my $class = shift;

    $class->$orig(yaml => YAML::Tiny->read('iller.yaml'));
};

sub parse {
    my $self = shift;
}

sub out {
    my $self = shift;

    use Data::Dump::Streamer;
    warn Dump($self->yaml)->Out;
}

1;
