use 5.10.0;
use strict;
use warnings;

package Dist::Zilla::MintingProfile::DistIller::Basic;

# AUTHORITY
our $VERSION = '0.1407';

use Moose;
use namespace::autoclean;
with 'Dist::Zilla::Role::MintingProfile::ShareDir';

__PACKAGE__->meta->make_immutable;

1;
