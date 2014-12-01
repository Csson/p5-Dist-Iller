package Dist::Zilla::Plugin::Iller::FirstBuild;

use Moose;
with 'Dist::Zilla::Role::AfterMint';

use File::pushd;

use Dist::Iller::App;

sub after_mint {
    my($self, $opts) = @_;

    my $wd = File::pushd::pushd($opts->{'mint_root'});

    for my $cmd (['build', '--no-tgz'], ['clean']) {
        local @ARGV = (@$cmd);
        Dist::Iller::App->run;
    }
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;
