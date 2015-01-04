package Dist::Zilla::Plugin::Iller::MetaGeneratedBy;

# VERSION

use Moose;
with 'Dist::Zilla::Role::MetaProvider';

use Dist::Iller;

sub metadata {
    return {
        generated_by => sprintf 'Dist::Iller version %s, Dist::Zilla version %s',
                                 Dist::Iller->VERSION,
                                 shift->zilla->VERSION,
    };
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;