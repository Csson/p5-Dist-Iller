use 5.10.0;
use strict;
use warnings;

package Dist::Zilla::Plugin::DistIller::MetaGeneratedBy;

# AUTHORITY
# ABSTRACT: Add Dist::Iller version to meta_data.generated_by
our $VERSION = '0.1410';

use Moose;
use namespace::autoclean;
with 'Dist::Zilla::Role::MetaProvider';

use Dist::Iller;

sub metadata {
    return {
        generated_by => sprintf 'Dist::Iller version %s, Dist::Zilla version %s',
                                 Dist::Iller->VERSION,
                                 shift->zilla->VERSION,
    };
}

__PACKAGE__->meta->make_immutable;

1;
