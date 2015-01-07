use 5.20.0;
use strict;
use warnings;

package Dist::Zilla::Plugin::Iller::CleanupDistIni;

# VERSION

use Moose;
use Dist::Iller::DistIniHandler;

with 'Dist::Zilla::Role::AfterBuild';


sub before_build {
    my $self = shift;
$self->log('builder');
    return if !$ENV{'ILLER_BUILDING'};
    $self->log('still');
    if(path('iller.ini')->exists) {
        $self->make_dist_ini;
    }
}

sub after_build {
    my $self = shift;

    return if !$ENV{'ILLER_BUILDING'};
    if(path('iller.ini')->exists) {
        Dist::Iller::DistIniHandler::make_dist_ini('PodWeaver', 'Iller::CleanupDistIni');
    }
}

1;