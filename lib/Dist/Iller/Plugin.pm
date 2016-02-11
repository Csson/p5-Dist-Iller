use 5.10.1;
use strict;
use warnings;

package Dist::Iller::Plugin;

our $VERSION = '0.1405';

use Dist::Iller::Elk;
use Types::Standard qw/Str Enum HashRef/;
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
    isa => Enum[qw/Plugin PluginBundle Section Elemental/],
    default => 'Plugin',
);
has version => (
    is => 'rw',
    isa => Str,
    default => '0',
);
has documentation => (
    is => 'ro',
    isa => Str,
    predicate => 1,
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
        parameters_kv => 'kv',
    },
);

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

sub to_string {
    my $self = shift;
    my %options = @_;

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
