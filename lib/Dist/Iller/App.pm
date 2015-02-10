package Dist::Iller::App;
use 5.10.1;
# VERSION

use strict;
use warnings;
use experimental 'postderef';
use parent 'Dist::Zilla::App';
use IPC::Run;
use File::chdir;
use Git::Wrapper;
use Path::Tiny;
use YAML::Tiny;
use Dist::Iller::Builder;

sub _default_command_base { 'Dist::Zilla::App::Command' }

sub prepare_command {
    my $self = shift;
    my($cmd, $opt, @args) = $self->SUPER::prepare_command(@_);

    if ($cmd->isa('Dist::Zilla::App::Command::new')) {
        $opt->{'profile'} = defined $opt->{'profile'} && $opt->{'profile'} eq 'default' ? 'iller' : $opt->{'profile'};
        $opt->{'provider'} = defined $opt->{'profile'} && $opt->{'provider'} eq 'Default' ? 'Iller' : $opt->{'provider'};

        IPC::Run::run [qw/dzil new/, '--provider', $opt->{'provider'}, '--profile', $opt->{'profile'}, $args[0] ];
        my $dir = $args[0];
        $dir =~ s{::}{-}g;

        if($opt->{'initgit'}) {
            $CWD = $dir;
            my $git = Git::Wrapper->new('.');
            $git->add('.');
            $git->commit(qw/ --message Init /, { all => 1 });
            IPC::Run::run [qw/dzil build --no-tgz/];
            IPC::Run::run [qw/dzil clean/];
            $git->add('.');
            $git->commit(qw/ --message Init /, { all => 1 });
        }
        exit;
    }

  #  generate_from_yaml();
    my $builder = Dist::Iller::Builder->new->parse;
    $builder->generate_dist_ini if defined $builder;
    $builder->generate_weaver_ini if defined $builder;


    if($cmd->isa('Dist::Zilla::App::Command::install')) {
        $opt->{'install_command'} ||= 'cpanm .';
    }
    elsif($cmd->isa('Dist::Zilla::App::Command::release')) {
        $ENV{'DZIL_CONFIRMRELEASE_DEFAULT'} // 1;
    }

    return $cmd, $opt, @args;
}
sub execute_command {
    my $self = shift;
    $self->SUPER::execute_command(@_);

}

1;
