use 5.10.1;
use strict;
use warnings;

package Dist::Iller::Builder;

# VERSION

use Dist::Iller::Elk;
use namespace::autoclean;
use Carp;
use Try::Tiny;
use Module::Load qw/load/;
use Safe::Isa qw/$_can/;
use PerlX::Maybe;
use DateTime;
use Path::Tiny;
use YAML::Tiny;
use List::Util qw/none/;
use Dist::Iller::Configuration;
use Dist::Iller::Configuration::Plugin;
use Dist::Iller::Configuration::Prereq;
use Dist::Iller::Doctype;
use Dist::Iller::Types -types;
use Types::Path::Tiny qw/Path/;
use Types::Standard qw/HashRef ConsumerOf Maybe Str/;

has dist => (
    is => 'ro',
    init_arg => undef,
    lazy => 1,
    predicate => 1,
    isa => IllerConfiguration,
    default => sub { Dist::Iller::Configuration->new(doctype => Dist::Iller::Doctype->dist) },
);
has weaver => (
    is => 'ro',
    init_arg => undef,
    lazy => 1,
    predicate => 1,
    isa => IllerConfiguration,
    default => sub { Dist::Iller::Configuration->new(doctype => Dist::Iller::Doctype->weaver) },
);
has filepath => (
    is => 'ro',
    isa => Path,
    default => 'iller.yaml',
    coerce => 1,
);
has current_config => (
    is => 'rw',
    isa => ConsumerOf['Dist::Iller::Role::Config'],
    predicate => 1,
    clearer => 1,
);
has included_configs => (
    is => 'ro',
    isa => HashRef,
    traits => ['Hash'],
    default => sub { { } },
    handles => {
        set_included_config => 'set',
        all_included_configs => 'kv',
    },
);

sub parse {
    my $self = shift;

    my $yaml = YAML::Tiny->read($self->filepath->stringify);

    foreach my $document (@$yaml) {
        if($document->{'doctype'} eq 'dist') {
            $self->parse_doc($self->dist, $document);
        }
        elsif($document->{'doctype'} eq 'weaver') {
            $self->parse_doc($self->weaver, $document);
        }
    }
    $self->dist->add_prereqs_from_configuration($self->weaver);
    $self->dist->add_prereq_plugins;

    return $self;
}

sub generate_dist_ini {
    my $self = shift;

    $self->generate_ini('dist.ini', $self->dist);
}
sub generate_weaver_ini {
    my $self = shift;

    $self->generate_ini('weaver.ini', $self->weaver);
}

sub make_contents_ready_for_compare {
    my $self = shift;
    my $contents = shift;

    $contents =~ s{^;.*(?=\v)}{}g;
    $contents =~ s{\v+}{\n}g;

    return $contents;
}

# $filename: Path (coerce)
# $config: Illerconfiguration
sub generate_ini {
    my $self = shift;
    my $filename = shift;
    my $config = shift;

    $filename = Path->check($filename) ? $filename : Path->coerce($filename);

    my $timestamp = DateTime->now;
    my $intro = sprintf qq{; This file was auto-generated from iller.yaml on %s %s %s.\n}, $timestamp->ymd, $timestamp->hms, $timestamp->time_zone->name;
    if(scalar $self->all_included_configs) {
        $intro .= join "\n" => ('; Used configs:', map { "; * $_->[0]: $_->[1]" } $self->all_included_configs);
    }
    $intro .= "\n\n";

    my $contents = $intro . $config->to_string;

    if(path($filename)->exists) {
        my $current_contents = $self->make_contents_ready_for_compare(path($filename)->slurp_utf8);
        my $copied_contents = $self->make_contents_ready_for_compare($contents);

        if($current_contents ne $copied_contents) {
            path($filename)->spew_utf8( $contents);
            say "[DI] Generated $filename";
        }
        else {
            say "[DI] No changes for $filename";
        }
    }
    else {
        if(!$config->has_plugins) {
            say "[DI] No plugins for $filename, does not create.";
            return;
        }
        path($filename)->spew_utf8($intro, $contents);
        say "[DI] Generated $filename";
    }
}

# $set: IllerConfiguration
# $yaml: HashRef
sub parse_doc {
    my $self = shift;
    my $set = shift;
    my $yaml = shift;

    if(exists $yaml->{'header'}) {
        my $header = delete $yaml->{'header'};

        foreach my $setting (qw/name author license copyright_holder copyright_year/) {
            my $predicate = "has_$setting";
            if(exists $header->{ $setting } && !$set->$predicate) {
                $set->$setting($header->{ $setting });
            }
        }
    }
    if(exists $yaml->{'prereqs'}) {
        $self->parse_prereqs($set, delete $yaml->{'prereqs'});
    }
    if(exists $yaml->{'plugins'}) {
        $self->parse_plugins($set, $yaml->{'plugins'});
    }
}

# $set: IllerConfiguration
# $plugins
sub parse_plugins {
    my $self = shift;
    my $set = shift;
    my $plugins = shift;

    foreach my $item (@$plugins) {
        $self->parse_plugin($set, $item) if exists $item->{'+plugin'};
        $self->parse_config($set, $item) if exists $item->{'+config'};
        $self->parse_remove($set, $item) if exists $item->{'+remove_plugin'};
        $self->parse_replace($set, $item) if exists $item->{'+replace_plugin'};
        $self->parse_extend($set, $item) if exists $item->{'+extend_plugin'};
        $self->parse_add($set, $item) if exists $item->{'+add_plugin'};
    }
}

# $set: IllerConfiguration
# $config: HashRef
sub parse_config {
    my $self = shift;
    my $set = shift;
    my $config = shift;

    my $config_name = delete $config->{'+config'};
    my $config_class = "Dist::Iller::Config::$config_name";

    try {
        load "$config_class";
    }
    catch {
        croak "Can't find $config_class ($_)";
    };

    my $configobj = $config_class->new(%$config, maybe distribution_name => $set->name);
    $self->set_included_config($configobj->meta->name, $config_class->VERSION);
    $self->current_config($configobj);

    my $configdoc = $configobj->get_yaml_for($set->doctype);
    $self->parse_doc($set, $configdoc);
    $self->clear_current_config;
}

# $set: IllerConfiguration
# $plugin: HashRef
sub parse_plugin {
    my $self = shift;
    my $set = shift;
    my $plugin = shift;

    my $plugin_name = delete $plugin->{'+plugin'};

    return if !$self->check_conditionals($plugin);

    $set->add_plugin({
                plugin_name => $self->set_value_from_config($plugin_name),
          maybe base => delete $plugin->{'+base'},
          maybe in => delete $plugin->{'+in'},
                parameters => $self->set_values_from_config($plugin),
    });
}

# $set: IllerConfiguration
# $replacer: HashRef
sub parse_replace {
    my $self = shift;
    my $set = shift;
    my $replacer = shift;

    return if !$self->check_conditionals($replacer);

    my $plugin_name = $self->set_value_from_config(delete $replacer->{'+replace_plugin'});
    my $replace_with = $self->set_value_from_config(delete $replacer->{'+with'});

    my $plugin = Dist::Iller::Configuration::Plugin->new(
                plugin_name => $replace_with // $plugin_name,
          maybe base => delete $replacer->{'+base'},
          maybe in => delete $replacer->{'+in'},
                parameters => $self->set_values_from_config($replacer),
    );

    $set->insert_plugin($plugin_name, $plugin, after => 0, replace => 1);
}

# $set: IllerConfiguration
# $extender: HashRef
sub parse_extend {
    my $self = shift;
    my $set = shift;
    my $extender = shift;

    return if !$self->check_conditionals($extender);

    my $plugin_name = delete $extender->{'+extend_plugin'};

    my $plugin = Dist::Iller::Configuration::Plugin->new(
                plugin_name => $self->set_value_from_config($plugin_name),
                parameters => $self->set_values_from_config($extender),
    );

    $set->extend_plugin($plugin_name, $plugin, remove => delete $extender->{'+remove'});
}

# $set: IllerConfiguration
# $adder: HashRef
sub parse_add {
    my $self = shift;
    my $set = shift;
    my $adder = shift;

    return if !$self->check_conditionals($adder);

    my $plugin_name = delete $adder->{'+add_plugin'};

    my $plugin = Dist::Iller::Configuration::Plugin->new(
                plugin_name => $self->set_value_from_config($plugin_name),
          maybe base => delete $adder->{'+base'},
          maybe in => delete $adder->{'+in'},
                parameters => $self->set_values_from_config($adder),
    );

    my $after = delete $adder->{'+after'};
    my $before = delete $adder->{'+before'};

    $set->insert_plugin(($after ? $after : $before), $plugin, after => ($after ? 1 : 0), replace => 0);
}

# $set: IllerConfiguration
# $remover: HashRef
sub parse_remove {
    my $self = shift;
    my $set = shift;
    my $remover = shift;

    return if !$self->check_conditionals($remover);

    $set->remove_plugin($self->set_value_from_config($remover->{'+remove_plugin'}));
}

# $set: IllerConfiguration
# $prereqs: HashRef
sub parse_prereqs {
    my $self = shift;
    my $set = shift;
    my $prereqs = shift;

    foreach my $phase (qw/build configure develop runtime test/) {

        foreach my $relation (qw/requires recommends suggests conflicts/) {

            foreach my $module (@{ $prereqs->{ $phase }{ $relation } }) {
                my $module_name = ref $module eq 'HASH' ? (keys %$module)[0] : $module;
                my $version     = ref $module eq 'HASH' ? (values %$module)[0] : 0;

                $set->add_prereq(Dist::Iller::Configuration::Prereq->new(
                    module => $module_name,
                    phase => $phase,
                    relation => $relation,
                    version => $version,
                ));
            }
        }
    }
}

sub set_values_from_config {
    my $self = shift;
    my $parameters = shift;

    return $parameters if !$self->has_current_config;

    foreach my $param (keys %$parameters) {
        next if $param =~ m{^\+};
        next if !defined $parameters->{ $param };

        $parameters->{ $param } = ref $parameters->{ $param } eq 'ARRAY' ? $parameters->{ $param } : [ $parameters->{ $param } ];

        VALUE:
        foreach my $i (0 .. scalar @{ $parameters->{ $param } } - 1) {
            $parameters->{ $param }[$i] = $self->set_value_from_config($parameters->{ $param }[$i]);
        }
    }
    return $parameters;
}

# $value: Maybe[Str]
sub set_value_from_config {
    my $self = shift;
    my $value = shift;

    return $value if !defined $value;
    return $value if $value !~ m{[^.]\.[^.]};
    my($type, $what) = split /\./ => $value;
    return $value if none { $_ eq $type } qw/$env $self/;

    if($type eq '$env' && exists $ENV{ uc $what }) {
        return $ENV{ uc $what };
    }
    elsif($type eq '$self' && $self->current_config->$_can($what)) {
        return $self->current_config->$what;
    }
    return $value;
}

# $plugin_data: HashRef
sub check_conditionals {
    my $self = shift;
    my $plugin_data = shift;

    if(exists $plugin_data->{'+if'}) {
        my($type, $what) = $self->get_type_what($plugin_data->{'+if'});
        return if !defined $type;

        if($type eq '$env') {
            return 0 if !$ENV{ uc $what };
        }
    }
    elsif(exists $plugin_data->{'+remove_if'}) {
        my($type, $what) = $self->get_type_what($plugin_data->{'+remove_if'});
        return if !defined $type;

        if($type eq '$env') {
            return 0 if !exists $ENV{ uc $what };
            return !$ENV{ uc $what };
        }
        elsif($type eq '$self' && $self->has_current_config) {
            return 1 if !$self->current_config->$_can($what);
            return !$self->current_config->$what;
        }
    }
    elsif(exists $plugin_data->{'+add_if'}) {
        my($type, $what) = $self->get_type_what($plugin_data->{'+add_if'});
        return if !defined $type;

        if($type eq '$env') {
            return 0 if !exists $ENV{ uc $what };
            return $ENV{ uc $what };
        }
        elsif($type eq '$self' && $self->has_current_config) {
            return 0 if !$self->current_config->$_can($what);
            return $self->current_config->$what;
        }
    }

    return 1;
}

sub get_type_what {
    my $self = shift;
    my $from = shift;

    return () if !defined $from;
    return () if !length $from;
    return () if $from !~ m{[^.]\.[^.]};
    return split /\./ => $from;
}

sub plugin_name_out {
    my $plugin = shift;

    return sprintf '[%s]', delete $plugin->{'plugin'};
}

__PACKAGE__->meta->make_immutable;

1;
