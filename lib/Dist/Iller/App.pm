package Dist::Iller::App;

# VERSION

use strict;
use warnings;
use experimental 'postderef';
use parent 'Dist::Zilla::App';
use IPC::Run;
use File::chdir;
use Git::Wrapper;
use Path::Tiny;
use YAML::XS;

sub _default_command_base { 'Dist::Zilla::App::Command' }

sub prepare_command {
    my $self = shift;

    generate_from_yaml();
    my($cmd, $opt, @args) = $self->SUPER::prepare_command(@_);
    $opt->{'profile'} = defined $opt->{'profile'} && $opt->{'profile'} eq 'default' ? 'iller' : $opt->{'profile'};
    $opt->{'provider'} = defined $opt->{'profile'} && $opt->{'provider'} eq 'Default' ? 'Iller' : $opt->{'provider'};

    if($cmd->isa('Dist::Zilla::App::Command::install')) {
        $opt->{'install_command'} ||= 'cpanm .';
    }
    elsif($cmd->isa('Dist::Zilla::App::Command::release')) {
        $ENV{'DZIL_CONFIRMRELEASE_DEFAULT'} // 1;
    }
    elsif ($cmd->isa('Dist::Zilla::App::Command::new')) {
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

    return $cmd, $opt, @args;
}
sub execute_command {
    my $self = shift;
    $self->SUPER::execute_command(@_);

}

sub generate_from_yaml {
    warn 'No iller.yaml to generate from' and return if !path('iller.yaml')->exists;
    warn 'Generating...';
    my $yaml = path('iller.yaml')->slurp_utf8;
    my @configs = YAML::XS::Load($yaml);

    foreach my $config (@configs) {
        if(ref $config eq 'dist') {
            generate_distini_from_yaml($config);
        }
        elsif(ref $config eq 'weaver') {
            generate_weaverini_from_yaml($config);
        }
    }
}

sub generate_distini_from_yaml {
    my $config = shift;

    my $plugins = delete $config->{'plugins'};

    my @contents = ();
    foreach my $key ('name', sort grep { $_ ne 'name' } keys %$config) {
        push @contents => kv_out($config, $key);
    }
    push @contents => '';
    foreach my $plugin (@$plugins) {
        push @contents => plugin_name_out($plugin);

        foreach my $key (sort keys %$plugin) {
            push @contents => kv_out($plugin, $key);
        }
        push @contents => '';
    }
    my $contents = join "\n" => @contents, '';
    path('dist.ini')->spew_utf8(join "\n" => $contents);
}

sub kv_out {
    my $structure = shift;
    my $key = shift;

    return sprintf '%s = %s', $key, $structure->{ $key };
}

sub plugin_name_out {
    my $plugin = shift;

    return sprintf '[%s]', delete $plugin->{'plugin'};
}

1;
