use 5.10.1;
use warnings;

package Dist::Iller::Config::DistIllerTestConfig;

our $VERSION = '0.0001';

use Moose;
use namespace::autoclean;
use Types::Standard qw/Str Bool/;
use Types::Path::Tiny qw/Path/;

has filepath => (
    is => 'ro',
    isa => Path,
    default => 't/corpus/03-config-config.yaml',
    coerce => 1,
);
has no_manifest_skip => (
    is => 'ro',
    isa => Bool,
    default => 0,
);
has prompt => (
    is => 'ro',
    isa => Str,
    default => '>',
);
has is_task => (
    is => 'ro',
    isa => Bool,
    default => 0,
);

with 'Dist::Iller::Role::Config';

sub package { __PACKAGE__ }

__PACKAGE__->meta->make_immutable;

1;
