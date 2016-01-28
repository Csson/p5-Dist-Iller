use 5.10.1;
use strict;
use warnings;

package Dist::Iller::Configuration::Prereq;

# VERSION

use Dist::Iller::Elk;
use namespace::autoclean;
use Types::Standard qw/Str Enum/;

has module => (
    is => 'ro',
    isa => Str,
    required => 1,
);
has phase => (
    is => 'ro',
    isa => Enum[qw/build configure develop runtime test/],
    required => 1,
);
has relation => (
    is => 'ro',
    isa => Enum[qw/requires recommends suggests conflicts/],
    required => 1,
);
has version => (
    is => 'ro',
    isa => Str,
    default => '0',
);

__PACKAGE__->meta->make_immutable;

1;
