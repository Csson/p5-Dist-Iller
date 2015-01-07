use 5.20.0;
use strict;
use warnings;

package Dist::Zilla::Plugin::Iller::CleanupDistIni;

# VERSION

use Moose;
use Dist::Iller::DistIniHandler;
use Path::Tiny;

with ('Dist::Zilla::Role::AfterBuild', 'Dist::Zilla::Role::FileMunger');
with 'Dist::Zilla::Role::FileFinderUser' => { default_finders => [qw/:All/] };

my @plugins_to_remove_on_build = ('PodWeaver', 'Iller::CleanupDistIni');

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
        Dist::Iller::DistIniHandler::make_dist_ini(@plugins_to_remove_on_build);
    }
}

sub munge_files {
    my $self = shift;

    foreach my $file (@{ $self->found_files }) {
        next if $file->name ne 'dist.ini';
        $file->content(Dist::Iller::DistIniHandler::dist_ini_string(@plugins_to_remove_on_build));
    }
}

1;
