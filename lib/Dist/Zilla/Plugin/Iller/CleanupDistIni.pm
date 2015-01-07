use 5.20.0;
use strict;
use warnings;

package Dist::Zilla::Plugin::Iller::CleanupDistIni;

# VERSION

use Moose;
use Path::Tiny;
use Dist::Zilla::Util::BundleInfo;
use Config::INI::Reader;
use List::AllUtils 'any';
with ('Dist::Zilla::Role::BeforeBuild', 'Dist::Zilla::Role::AfterBuild');


sub before_build {
    my $self = shift;

    if(path('iller.ini')->exists) {
        $self->make_dist_ini;
    }
}

sub after_build {
    my $self = shift;

    if(path('iller.ini')->exists) {
        $self->make_dist_ini('PodWeaver');
    }
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