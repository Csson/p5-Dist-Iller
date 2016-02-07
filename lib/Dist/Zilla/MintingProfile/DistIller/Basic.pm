use 5.10.1;
use strict;
use warnings;

package Dist::Zilla::MintingProfile::DistIller::Basic;

our $VERSION = '0.1401';

use Moose;
use namespace::autoclean;
with 'Dist::Zilla::Role::MintingProfile::ShareDir';

__PACKAGE__->meta->make_immutable;

1;
