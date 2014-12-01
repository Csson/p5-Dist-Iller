package Dist::Zilla::Plugin::Iller::FirstBuild;

use Moose;
with 'Dist::Zilla::Role::AfterMint';

use Dist::Iller::App;
use File::pushd;
use Git::Wrapper;

sub after_mint {
    my($self, $opts) = @_;

    $self->log('Initial build and cleanup');

    {
        my $wd = File::pushd::pushd($opts->{'mint_root'});
        for my $cmd (['build', '--no-tgz'], ['clean']) {
            local @ARGV = (@$cmd);
            Dist::Iller::App->run;
        }
    }

    my $git = Git::Wrapper->new($opts->{'mint_root'});
    $git->add($opts->{'mint_root'});
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;
