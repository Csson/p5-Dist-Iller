package Dist::Iller::App;

# VERSION

use 5.20.0;
use strict;
use warnings;
use experimental 'postderef';
use parent 'Dist::Zilla::App';
use IPC::Run;
use File::chdir;
use Git::Wrapper;


sub _default_command_base { 'Dist::Zilla::App::Command' }

sub prepare_command {
    my $self = shift;

    my($cmd, $opt, @args) = $self->SUPER::prepare_command(@_);
    $ENV{'ILLER_BUILDING'} = 1;

    if($cmd->isa('Dist::Zilla::App::Command::install')) {
        $opt->{'install_command'} ||= 'cpanm .';
    }
    elsif($cmd->isa('Dist::Zilla::App::Command::release')) {
        $ENV{'DZIL_CONFIRMRELEASE_DEFAULT'} // 1;
    }
    elsif ($cmd->isa('Dist::Zilla::App::Command::new')) {
        $ENV{'ILLER_MINTING'} = 1;
        IPC::Run::run [qw/dzil new --provider Author::CSSON --profile csson/, $args[0] ];
        my $dir = $args[0];
        $dir =~ s{::}{-}g;

        $CWD = $dir;
        my $git = Git::Wrapper->new('.');
        $git->add('.');
        $git->commit(qw/ --message Init /, { all => 1 });
        IPC::Run::run [qw/dzil build --no-tgz/];
        IPC::Run::run [qw/dzil clean/];
        $git->add('.');
        $git->commit(qw/ --message Init /, { all => 1 });
        exit;
    }

    return $cmd, $opt, @args;
}
sub execute_command {
    my $self = shift;
    $self->SUPER::execute_command(@_);

}

sub make_dist_ini {
    my @plugins_to_remove = @_;

    my $out = "; This file has been auto-generated\n\n";
    my $iller = Config::INI::Reader->read_file('iller.ini');

    foreach my $headerkey (sort keys $iller->{'_'}->%*) {
        $out .= sprintf "%s = %s\n", $headerkey, $iller->{'_'}{ $headerkey };
    }
    $out .= "\n";
    delete $iller->{'_'};

    PLUGIN:
    foreach my $plugin (sort keys $iller->%*) {
        next PLUGIN if any { $plugin eq $_ } @plugins_to_remove;

        # Bundle?
        if($plugin =~ m{^@}) {
            my $settings = [ map { $_ => $iller->{ $plugin }{ $_ } } keys $iller->{ $plugin }->%* ];
            my $bundle = Dist::Zilla::Util::BundleInfo->new(bundle_name => $plugin, bundle_payload => $settings);

            foreach my $plugin_in_bundle ($bundle->plugins) {
                $out .= $plugin_in_bundle->to_dist_ini;
                $out .= "\n";
            }
        }
        else {
            $out .= sprintf "[%s]\n", $plugin;

            foreach my $setting (sort keys $iller->{ $plugin }->%*) {
                $out .= sprintf "%s = %s" => $setting, $iller->{ $plugin }{ $setting };
            }
            $out .= "\n";
        }
    }

    path('dist.ini')->touch->spew_utf8($out);
            warn '   Has generated dist.ini';
}

1;
