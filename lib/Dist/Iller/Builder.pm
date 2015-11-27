use feature ':5.14';
use strict;
use warnings;
use Dist::Iller::Standard;

# PODCLASSNAME

use DateTime;
use YAML::Tiny;
use Dist::Iller::Configuration;
use Dist::Iller::Configuration::Plugin;
use Dist::Iller::Configuration::Prereq;
use Dist::Iller::Doctype;

class Dist::Iller::Builder using Moose {

    # VERSION

    use Safe::Isa qw/$_can/;
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

    method parse {
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

    method generate_dist_ini {
        $self->generate_ini('dist.ini', $self->dist);
    }
    method generate_weaver_ini {
        $self->generate_ini('weaver.ini', $self->weaver);
    }

    method make_contents_ready_for_compare(Str $contents) {
        $contents =~ s{^;.*(?=\v)}{}g;
        $contents =~ s{\v+}{\n}g;

        return $contents;
    }

    method generate_ini(Path $filename does coerce, IllerConfiguration $config) {
        my $timestamp = DateTime->now;
        my $intro = sprintf qq{; This file was auto-generated from iller.yaml on %s %s %s.\n\n}, $timestamp->ymd, $timestamp->hms, $timestamp->time_zone->name;

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

    method parse_doc(IllerConfiguration $set, HashRef $yaml) {
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

    method parse_plugins(IllerConfiguration $set, $plugins) {
        foreach my $item (@$plugins) {
            $self->parse_plugin($set, $item) if exists $item->{'+plugin'};
            $self->parse_config($set, $item) if exists $item->{'+config'};
            $self->parse_remove($set, $item) if exists $item->{'+remove_plugin'};
            $self->parse_replace($set, $item) if exists $item->{'+replace_plugin'};
            $self->parse_extend($set, $item) if exists $item->{'+extend_plugin'};
            $self->parse_add($set, $item) if exists $item->{'+add_plugin'};
        }
    }

    method parse_config(IllerConfiguration $set, HashRef $config) {
        my $config_name = delete $config->{'+config'};

        eval "use Dist::Iller::Config::$config_name";
        if($@) {
            die "Can't find Dist::Iller::Config::$config_name ($@) in: \n  " . join "\n  " => @INC;
        }

        my $configobj = "Dist::Iller::Config::$config_name"->new(%$config, maybe distribution_name => $set->name);
        $self->current_config($configobj);

        my $configdoc = $configobj->get_yaml_for($set->doctype);
        $self->parse_doc($set, $configdoc);
        $self->clear_current_config;
    }

    method parse_plugin(IllerConfiguration $set, HashRef $plugin) {
        my $plugin_name = delete $plugin->{'+plugin'};

        return if !$self->check_conditionals($plugin);

        $set->add_plugin({
                    plugin_name => $self->set_value_from_config($plugin_name),
              maybe base => delete $plugin->{'+base'},
              maybe in => delete $plugin->{'+in'},
                    parameters => $self->set_values_from_config($plugin),
        });
    }

    method parse_replace(IllerConfiguration $set, HashRef $replacer) {
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

    method parse_extend(IllerConfiguration $set, HashRef $extender) {
        return if !$self->check_conditionals($extender);

        my $plugin_name = delete $extender->{'+extend_plugin'};

        my $plugin = Dist::Iller::Configuration::Plugin->new(
                    plugin_name => $self->set_value_from_config($plugin_name),
                    parameters => $self->set_values_from_config($extender),
        );

        $set->extend_plugin($plugin_name, $plugin, remove => delete $extender->{'+remove'});
    }

    method parse_add(IllerConfiguration $set, HashRef $adder) {
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

    method parse_remove(IllerConfiguration $set, HashRef $remover) {
        return if !$self->check_conditionals($remover);

        $set->remove_plugin($self->set_value_from_config($remover->{'+remove_plugin'}));
    }

    method parse_prereqs(IllerConfiguration $set, HashRef $prereqs) {

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

    method set_values_from_config($parameters) {
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
    method set_value_from_config(Maybe[Str] $value) {
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

    method check_conditionals(HashRef $plugin_data) {

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

    method get_type_what(Str $from) {
        return () if !defined $from;
        return () if !length $from;
        return () if $from !~ m{[^.]\.[^.]};
        return split /\./ => $from;
    }

    sub plugin_name_out {
        my $plugin = shift;

        return sprintf '[%s]', delete $plugin->{'plugin'};
    }

}

1;
