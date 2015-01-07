use 5.20.0;
use strict;
use warnings;

package Dist::Iller::DistIniHandler;

use Path::Tiny;
use Dist::Zilla::Util::BundleInfo;
use Config::INI::Reader;
use DateTime;
use List::AllUtils 'any';
use experimental 'postderef';

sub dist_ini_string {
    my @plugins_to_remove = @_;

    my $timestamp = DateTime->now;
    my $out = sprintf "; This file was auto-generated %s %s\n\n", $timestamp->ymd, $timestamp->hms;
    my $iller = Config::INI::Reader->read_file('iller.ini');

    foreach my $headerkey (sort keys $iller->{'_'}->%*) {
        $out .= sprintf "%s = %s\n", $headerkey, $iller->{'_'}{ $headerkey };
    }
    $out .= "\n";
    delete $iller->{'_'};

    PLUGIN:
    foreach my $plugin (sort keys $iller->%*) {

        # Bundle?
        if($plugin =~ m{^@}) {
            my $settings = [ map { $_ => $iller->{ $plugin }{ $_ } } keys $iller->{ $plugin }->%* ];
            my $bundle = Dist::Zilla::Util::BundleInfo->new(bundle_name => $plugin, bundle_payload => $settings);

            PLUGIN_IN_BUNDLE:
            foreach my $plugin_in_bundle ($bundle->plugins) {
                if(any { $plugin_in_bundle->{'name'} =~ m{.*/$_} } @plugins_to_remove) {
                    warn sprintf '[PluginRemover] Removed plugin %s', $plugin_in_bundle->{'name'};
                    next PLUGIN_IN_BUNDLE;
                }
                my $fordistini = $plugin_in_bundle->to_dist_ini;
                $fordistini =~ s{ / Dist::Zilla::PluginBundle::Author::CSSON/[^/ ]+]}{]};
                $out .= $fordistini;
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
    return $out;
}

sub make_dist_ini {
    my @plugins_to_remove = @_;

    my $out = dist_ini_string(@plugins_to_remove);

    path('dist.ini')->touch->spew_utf8($out);
            warn '   Has generated dist.ini';
}

1;
