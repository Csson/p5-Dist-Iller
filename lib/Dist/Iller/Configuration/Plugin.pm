use 5.10.1;
use strict;
use warnings;

package Dist::Iller::Configuration::Plugin;

# VERSION

use Dist::Iller::Elk;
use namespace::autoclean;
use Types::Standard qw/Str Enum HashRef/;
use Dist::Iller::Types -types;
use List::MoreUtils qw/uniq/;
use MooseX::StrictConstructor;

has plugin_name => (
    is => 'ro',
    isa => Str,
);
has base => (
    is => 'ro',
    isa => Str,
    predicate => 1,
);
has in => (
    is => 'rw',
    predicate => 1,
    isa => Enum[qw/Plugin PluginBundle Section Elemental/],
    default => 'Plugin',
);
has version => (
    is => 'rw',
    isa => Str,
    default => '0',
);
has parameters => (
    is => 'ro',
    isa => HashRef,
    traits => [qw/Hash/],
    handles => {
        set_parameter => 'set',
        get_parameter => 'get',
        parameter_keys => 'keys',
        delete_parameter => 'delete',
    },
);

# $other_plugin: IllerConfigurationPlugin
sub merge_with {
    my $self = shift;
    my $other_plugin = shift;

    foreach my $param ($other_plugin->parameter_keys) {
        if($self->get_parameter($param)) {
            if(ref $other_plugin->get_parameter($param) eq 'ARRAY') {
                if(ref $self->get_parameter($param) eq 'ARRAY') {
                    my $new_param_data = [ uniq @{ $self->get_parameter($param) }, @{ $other_plugin->get_parameter($param) } ];
                    $self->set_parameter($param, $new_param_data);
                }
                else {
                    my $new_param_data = [ uniq ($self->get_parameter($param)), @{ $other_plugin->get_parameter($param) } ];
                    $self->set_parameter($param, $new_param_data);
                }
            }
            else {
                $self->set_parameter($param, $other_plugin->get_parameter($param));
            }
        }
        else {
            $self->set_parameter($param, $other_plugin->get_parameter($param));
        }
    }
}

# $doctype: IllerDoctype
sub plugin_package {
    my $self = shift;
    my $doctype = shift;

    my @packages = ();
    # For -Transformer
    if($doctype->is_weaver && $self->has_in && $self->has_base) {
        if($self->in eq 'Elemental') {
            my $base = $self->base;
            $base =~ s{^[^a-zA-Z]}{};

            push @packages => join '::' => 'Pod::Elemental', $base, $self->plugin_name;
            $self->in('Plugin'); # eg. Pod::Elemental::Transformer -> Pod::Weaver::Plugin::Transformer (a bit messy)
        }
    }
    my $name = $self->has_base ? $self->base : $self->plugin_name;
    $name =~ m{^(.)};
    my $first = $1;

    my $clean_name = $name;
    $clean_name =~ s{^[-%=@]}{};

    if($doctype->is_dist) {
        push @packages => $first eq '%' ? sprintf '%s::%s::%s' => $doctype->namespace, 'Stash', $clean_name
                       :  $first eq '@' ? sprintf '%s::%s::%s' => $doctype->namespace, 'PluginBundle', $clean_name
                       :  $first eq '=' ? sprintf $clean_name
                       :                  sprintf '%s::%s::%s' => $doctype->namespace, 'Plugin', $clean_name
                       ;
    }
    elsif($doctype->is_weaver) {
        push @packages => $first eq '-' ? sprintf '%s::%s::%s' => $doctype->namespace, 'Plugin', $clean_name
                       :  $first eq '@' ? sprintf '%s::%s::%s' => $doctype->namespace, 'PluginBundle', $clean_name
                       :  $first eq '=' ? sprintf $clean_name
                       :                  sprintf '%s::%s::%s' => $doctype->namespace, 'Section', $clean_name
                       ;
    }
    return @packages;
}

sub to_string {
    my $self = shift;
    my @strings = $self->has_base ? (sprintf '[%s / %s]' => $self->base, $self->plugin_name)
                :                   (sprintf '[%s]' => $self->plugin_name)
                ;

    foreach my $parameter (sort $self->parameter_keys) {
        next if $parameter =~ m{^\+};
        my $value = $self->get_parameter($parameter);

        if(ref $value eq 'ARRAY') {
            foreach my $val (@$value) {
                push @strings => sprintf '%s =%s%s', $parameter, defined $val ? ' ' : '', $val;
            }
        }
        else {
            push @strings => sprintf '%s =%s%s', $parameter, defined $value ? ' ' : '', $value // '';
        }
    }

    return join "\n" => @strings;
}

__PACKAGE__->meta->make_immutable;

1;
