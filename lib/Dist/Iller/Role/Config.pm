use 5.10.1;
use strict;
use warnings;

package Dist::Iller::Role::Config;

# VERSION

use Moose::Role;
use File::ShareDir 'dist_dir';
use Types::Standard qw/Str/;
use MooseX::AttributeShortcuts;
use Path::Tiny;
use Try::Tiny;

requires 'filepath';
has distribution_name => (
    is => 'ro',
    isa => Str,
);
has main_module => (
    is => 'ro',
    isa => Str,
    predicate => 1,
    documentation => q{Override this attribute when there's more than one config in a distribution. It uses the main_module's sharedir location for the config files.},
);

sub configlocation {
    my $self = shift;
    my $package = $self->has_main_module ? $self->main_module : $self->meta->name;
    $package =~ s{::}{-}g;
    my $dir = path('.');

    try {
        $dir = path(dist_dir($package));
    }
    finally { };

    return $dir->child($self->filepath);
}

# $doctype: IllerDoctype
sub get_yaml_for {
    my $self = shift;
    my $doctype = shift;

    return $self->get_yaml_for_dist if $doctype->type eq 'dist';
    return $self->get_yaml_for_weaver if $doctype->type eq 'weaver';
    return;
}

sub get_yaml_for_dist {
    my $self = shift;

    my $yaml = YAML::Tiny->read($self->configlocation->absolute->stringify);

    return (grep { $_->{'doctype'} eq 'dist'} @$yaml)[0];
}
sub get_yaml_for_weaver {
    my $self = shift;

    my $yaml = YAML::Tiny->read($self->configlocation->stringify);

    return (grep { $_->{'doctype'} eq 'weaver'} @$yaml)[0];
}

1;
