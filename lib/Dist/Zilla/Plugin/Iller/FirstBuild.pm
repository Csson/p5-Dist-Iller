package Dist::Zilla::Plugin::Iller::FirstBuild;

use Moose;
use 5.10.1;
with 'Dist::Zilla::Role::AfterMint';

use File::pushd;
use Git::Wrapper;
use Dist::Iller::App;

sub after_mint {
    my($self, $opts) = @_;

    my $wd = File::pushd::pushd($opts->{'mint_root'});
    my $git = Git::Wrapper->new('.');
    $git->init;
    $git->add('.');
say 'gitted';
say 'before';
    for my $cmd (['build', '--no-tgz'], ['clean']) {
        say '>> ' . join ' ' => @{ $cmd };
        local @ARGV = (@$cmd);
        say '>>>';
        Dist::Iller::App->run;
        say '>>>>';
    }
    say 'after';
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;
