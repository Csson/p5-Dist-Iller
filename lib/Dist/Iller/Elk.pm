use 5.14.0;
use strict;
use warnings;

package Dist::Iller::Elk;

# AUTHORITY
# ABSTRACT: A slightly extended Moose
our $VERSION = '0.1412';

use Moose();
use MooseX::AttributeShortcuts();
use MooseX::AttributeDocumented();
use namespace::autoclean();
use Moose::Exporter;

Moose::Exporter->setup_import_methods(also => ['Moose']);

sub init_meta {
    my $class = shift;

    my %params = @_;
    my $for_class = $params{'for_class'};
    Moose->init_meta(@_);
    MooseX::AttributeShortcuts->init_meta(for_class => $for_class);
    MooseX::AttributeDocumented->init_meta(for_class => $for_class);
    namespace::autoclean->import(-cleanee => $for_class);
}

1;
