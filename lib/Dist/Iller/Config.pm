use 5.10.1;
use strict;
use warnings;

package Dist::Iller::Config;

use Moose::Role;
use MooseX::AttributeShortcuts;
use Module::Load qw/load/;
use Types::Standard qw/Str/;
use YAML::Tiny;
use Path::Tiny;
use Try::Tiny;
use File::ShareDir 'dist_dir';
use String::CamelCase qw/camelize/;

requires qw/filepath/;

has main_module => (
    is => 'ro',
    isa => Str,
    predicate => 1,
    documentation => q{Override this attribute when there's more than one config in a distribution. It uses the main_module's sharedir location for the config files.},
);

sub config_location {
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

sub get_yaml_for {
    my $self = shift;
    my $doctype = shift;

    my $fullyaml = YAML::Tiny->read($self->config_location->absolute->stringify);

    my $yaml = (grep { $_->{'doctype'} eq $doctype } @{ $fullyaml })[0];
    return if !defined $yaml;

    my $doctype_class = sprintf 'Dist::Iller::DocType::%s', camelize($yaml->{'doctype'});
    try {
        load $doctype_class;
    }
    catch {
        die "Can't load $doctype_class: $_";
    };
    return $doctype_class->new(config_obj => $self)->parse($yaml)->to_yaml;

}

#sub get_yaml_for_dist {
#    my $self = shift;
#
#    my $yaml = YAML::Tiny->read($self->configlocation->absolute->stringify);
#
#    return (grep { $_->{'doctype'} eq 'dist'} @$yaml)[0];
#}

sub parse {
    my $self = shift;
    my $parse_only = shift;
}

1;

__END__
