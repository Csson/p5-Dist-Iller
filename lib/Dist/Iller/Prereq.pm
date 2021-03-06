use 5.14.0;
use strict;
use warnings;

package Dist::Iller::Prereq;

# AUTHORITY
# ABSTRACT: Handle a prerequisite
our $VERSION = '0.1412';

use Dist::Iller::Elk;
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
    is => 'rw',
    isa => Str,
    default => '0',
);

__PACKAGE__->meta->make_immutable;

1;
