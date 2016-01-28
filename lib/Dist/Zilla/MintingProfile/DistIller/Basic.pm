use 5.10.1;
use strict;
use warnings;

package Dist::Zilla::MintingProfile::DistIller::Basic;

# VERSION

use Moose;
use namespace::autoclean;
with 'Dist::Zilla::Role::MintingProfile::ShareDir';

__PACKAGE__->meta->make_immutable;

1;
