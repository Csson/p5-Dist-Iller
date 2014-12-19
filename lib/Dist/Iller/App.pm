package Dist::Iller::App;

use 5.10.1;
use strict;
use parent 'Dist::Zilla::App';
use IPC::Run;
use File::chdir;
use Git::Wrapper;

sub _default_command_base { 'Dist::Zilla::App::Command' }

sub prepare_command {
    my $self = shift;

    my($cmd, $opt, @args) = $self->SUPER::prepare_command(@_);

    if($cmd->isa('Dist::Zilla::App::Command::install')) {
        $opt->{'install_command'} ||= 'cpanm .';
    }
    elsif($cmd->isa('Dist::Zilla::App::Command::release')) {
        $ENV{'DZIL_CONFIRMRELEASE_DEFAULT'} // 1;
    }
    elsif ($cmd->isa('Dist::Zilla::App::Command::new')) {
        IPC::Run::run [qw/dzil new --provider Iller --profile iller/, $args[0] ];
        my $dir = $args[0];
        $dir =~ s{::}{-}g;

        $CWD = $dir;
        my $git = Git::Wrapper->new('.');
        $git->add('.');
        $git->commit(qw/ --message "Init." /, { all => 1 });
        IPC::Run::run [qw/dzil build --no-tgz/];
        IPC::Run::run [qw/dzil clean/];
        exit;
    }

    return $cmd, $opt, @args;
}

1;
