use 5.10.1;
use strict;
use warnings;

package Dist::Iller::Configuration;

# VERSION

use Dist::Iller::Elk;
use namespace::autoclean;

use List::MoreUtils qw/uniq/;
use Dist::Iller::Types -types;
use Types::Standard qw/Str ArrayRef Int Bool/;

has doctype => (
    is => 'ro',
    isa => IllerDoctype,
);
has name => (
    is => 'rw',
    isa => Str,
    predicate => 1,
);
has author => (
    is => 'rw',
    isa => ArrayRefStr,
    traits => ['Array'],
    default => sub { [ ] },
    coerce => 1,
    handles => {
        all_authors => 'elements',
        map_authors => 'map',
        has_author => 'count',
    },
);
has license => (
    is => 'rw',
    isa => Str,
    predicate => 1,
);
has copyright_holder => (
    is => 'rw',
    isa => Str,
    predicate => 1,
);
has copyright_year => (
    is => 'rw',
    isa => Int,
    predicate => 1,
);
has prereqs => (
    is => 'ro',
    isa => ArrayRef,
    traits => ['Array'],
    handles => {
        add_prereq => 'push',
        filter_prereqs => 'grep',
        get_prereq => 'get',
    },
);
has plugins => (
    is => 'rw',
    isa => ArrayRef[IllerConfigurationPlugin],
    traits => [qw/Array/],
    default => sub { [] },
    coerce => 1,
    handles => {
        add_plugin => 'push',
        all_plugins => 'elements',
        filter_plugins => 'grep',
        find_plugin => 'first',
        count_plugins => 'count',
        has_plugins => 'count',
        get_plugin => 'get',
    },
);

# $plugin_name: Str
# $new_plugin: IllerConfigurationPlugin
# %settings
sub insert_plugin {
    my $self = shift;
    my $plugin_name = shift;
    my $new_plugin = shift;
    my %settings = @_;

    my $after = $settings{'after'} || 0;
    my $replace = $settings{'replace'} || 0;

    foreach my $index (0 .. $self->count_plugins - 1) {
        my $current_plugin = $self->get_plugin($index);

        if($current_plugin->plugin_name eq $plugin_name) {
            my @all_plugins = $self->all_plugins;
            splice @all_plugins, ($after ? $index + 1 : $index), ($replace ? 1 : 0), $new_plugin;
            $self->plugins(\@all_plugins);

            if($replace) {
                say "[DI] Replaced [$plugin_name]";
            }
            else {
                say sprintf "[DI] Inserted [%s] %s [%s]", $new_plugin->plugin_name, ($after ? 'after' : 'before'), $current_plugin->plugin_name;
            }
            last;
        }
    }
}

# $plugin_name: Str
# $new_plugin: IllerConfigurationPlugin
# %settings
sub extend_plugin {
    my $self = shift;
    my $plugin_name = shift;
    my $new_plugin = shift;
    my %settings = @_;

    my $remove = $settings{'remove'};

    $remove = $remove ? ref $remove eq 'ARRAY' ? $remove
                                               : [ $remove ]
            :                                    []
            ;
    say sprintf '[DI] From %s remove %s', $plugin_name, join ', ' => @$remove if scalar @$remove;

    foreach my $index (0 .. $self->count_plugins - 1) {
        my $current_plugin = $self->get_plugin($index);

        if($current_plugin->plugin_name eq $plugin_name) {
            foreach my $param_to_remove (@$remove) {
                $current_plugin->delete_parameter($param_to_remove);
            }
            $current_plugin->merge_with($new_plugin);
            last;
        }
    }
}

sub remove_plugin {
    my $self = shift;
    my $remove_name = shift;

    foreach my $index (0 .. $self->count_plugins - 1) {
        my $current_plugin = $self->get_plugin($index);

        if($current_plugin->plugin_name eq $remove_name) {
            my @all_plugins = $self->all_plugins;
            splice @all_plugins, $index, 1;
            $self->plugins(\@all_plugins);
            say "[DI] Removed [$remove_name]";
            last;
        }
    }
}

sub add_prereq_plugins {
    my $self = shift;

    foreach my $phase (qw/build configure develop runtime test/) {
        RELATION:
        foreach my $relation (qw/requires recommends suggests conflicts/) {

            my @prereqs = $self->filter_prereqs(sub { $_->phase eq $phase && $_->relation eq $relation });
            next RELATION if !scalar @prereqs;

            my $plugin_name = sprintf '%s%s', ucfirst $phase, ucfirst $relation;
            $self->add_plugin({
                plugin_name => $plugin_name,
                base => 'Prereqs',
                parameters => { map { $_->module => $_->version } @prereqs },
            });
        }
    }
}

# $other_config: IllerConfiguration
sub add_prereqs_from_configuration {
    my $self = shift;
    my $other_config = shift;

    foreach my $plugin ($other_config->all_plugins) {

        # Usually only one, but for things like (in weaver) [-Transformer / Lists] we add
        # both Pod::Elemental::Transformer::List and Pod::Weaver::Plugin::Transformer.
        foreach my $plugin_package ($plugin->plugin_package($other_config->doctype)) {

            $self->add_prereq(Dist::Iller::Configuration::Prereq->new(
                module => $plugin_package,
                version => 0,
                phase => 'develop',
                relation => 'requires',
            ));
        }
    }
}

sub to_string {
    my $self = shift;

    my @strings = ();
    push @strings => sprintf 'name = %s', $self->name if $self->name;

    if($self->has_author) {
        push @strings => $self->map_authors(sub { qq{author = $_} });
    }
    push @strings => sprintf 'license = %s', $self->license if $self->has_license;
    push @strings => sprintf 'copyright_holder = %s', $self->copyright_holder if $self->has_copyright_holder;
    push @strings => sprintf 'copyright_year = %s', $self->copyright_year if $self->has_copyright_year;
    push @strings => '' if scalar @strings;

    foreach my $plugin ($self->all_plugins) {
        push @strings => $plugin->to_string, '';
    }
    my $had_author_deps = 0;
    foreach my $authordep_module (uniq map { $_->module } $self->filter_prereqs(sub { $_->relation eq 'requires' && $_->module ne 'perl' })) {
        push @strings => sprintf '; authordep %s', $authordep_module;
        ++$had_author_deps;
    }
    push @strings => '' if $had_author_deps;


    return join "\n" => @strings;
}

__PACKAGE__->meta->make_immutable;

1;

__END__
