use 5.14.0;
use strict;
use warnings;

package Dist::Zilla::MintingProfile::DistIller::Basic;

# AUTHORITY
# ABSTRACT: A basic minting profile for Dist::Iller
our $VERSION = '0.1412';

use Moose;
use namespace::autoclean;
with 'Dist::Zilla::Role::MintingProfile::ShareDir';

__PACKAGE__->meta->make_immutable;

1;
