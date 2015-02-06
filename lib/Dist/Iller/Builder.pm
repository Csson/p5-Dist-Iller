use Dist::Iller::Standard;

# VERSION
# PODCLASSNAME

use YAML::Tiny;
use Dist::Iller::Configuration;
use Dist::Iller::Configuration::Plugin;
use Dist::Iller::Doctype;

class Dist::Iller::Builder using Moose {

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

    method parse() {
        if(!path('dist.ini')->exists) {
            warn 'No dist.ini - quitting';
            return;
        }
        my $yaml = YAML::Tiny->read($self->filepath->stringify);
        foreach my $document (@$yaml) {
            if($document->{'+doctype'} eq 'dist') {
                next if $self->has_dist;
                $self->parse_doc($self->dist, $document);
            }
            elsif($document->{'+doctype'} eq 'weaver') {
                next if $self->has_weaver;
                $self->parse_doc($self->weaver, $document);
            }
        }
        return $self;
    }

    method generate_dist_ini {
        $self->generate_ini('dist.ini', $self->dist);
    }
    method generate_weaver_ini {
        $self->generate_ini('weaver.ini', $self->weaver);
    }

    method generate_ini($filename, $config) {
        my $plugins = delete $config->{'plugins'};

        my @contents = ();
        foreach my $key ('name', sort grep { $_ ne 'name' } keys %$config) {
            push @contents => kv_out($config, $key);
        }
        push @contents => '';
        foreach my $plugin (@$plugins) {
            push @contents => plugin_name_out($plugin);

            foreach my $key (sort keys %$plugin) {
                push @contents => kv_out($plugin, $key);
            }
            push @contents => '';
        }
        my $contents = join "\n" => @contents, '';
        if(path($filename)->exists) {
            my $current_contents = path($filename)->slurp_utf8;
            $current_contents =~ s{^;.*$}{}g;
            my $copied_contents = $contents;
            $copied_contents =~ s{^;.*$}{}g;
            if($current_contents ne $copied_contents) {
                path($filename)->spew_utf8($contents);
                say "Generated $filename";
            }
            else {
                say "No changes for $filename";
            }
        }
        else {
            path($filename)->spew_utf8(join "\n" => $contents);
            say "Generated $filename";
        }
    }

    method parse_doc(IllerConfiguration $set, HashRef $yaml) {
        foreach my $setting (qw/author license copyright_holder copyright_year/) {
            my $predicate = "has_$setting";
            if(exists $yaml->{ $setting } && !$set->$predicate) {
                $set->$setting($yaml->{ $setting });
            }
        }
        if(exists $yaml->{'plugins'}) {
            $self->parse_plugins($set, $yaml->{'plugins'});
        }
    }

    method parse_plugins(IllerConfiguration $set, $plugins) {
        foreach my $item (@$plugins) {
            $self->parse_plugin($set, $item) if exists $item->{'plugin'};
            $self->parse_config($set, $item) if exists $item->{'config'};
            $self->parse_remove($set, $item) if exists $item->{'remove_plugin'};
            $self->parse_replace($set, $item) if exists $item->{'replace_plugin'};
            $self->parse_extend($set, $item) if exists $item->{'extend_plugin'};
            $self->parse_add($set, $item) if exists $item->{'add_plugin'};
        }
    }

    method parse_config(IllerConfiguration $set, HashRef $config) {
        my $config_name = delete $config->{'config'};
        eval "use Dist::Iller::Config::$config_name";
        if($@) {
            die "Can't find Dist::Iller::Config::$config_name ($@) in: \n  " . join "\n  " => @INC;
        }

        my $configobj = "Dist::Iller::Config::$config_name"->new(%$config);
        $self->current_config($configobj);

        my $configdoc = $configobj->get_yaml_for($set->doctype);
        $self->parse_doc($set, $configdoc);
        $self->clear_current_config;
    }

    method parse_plugin(IllerConfiguration $set, HashRef $plugin) {
        my $plugin_name = delete $plugin->{'plugin'};

        return if !$self->check_conditionals($plugin);

        $set->add_plugin({
                    plugin => $plugin_name,
              maybe base => delete $plugin->{'+base'},
                    parameters => $self->set_values_from_config($plugin),
        });
    }

    method parse_replace(IllerConfiguration $set, HashRef $replacer) {
        return if !$self->check_conditionals($replacer);

        my $plugin_name = delete $replacer->{'replace_plugin'};
        my $replace_with = delete $replacer->{'+with'};

        my $plugin = Dist::Iller::Configuration::Plugin->new(
                    plugin => $replace_with // $plugin_name,
              maybe base => delete $replacer->{'+base'},
                    parameters => $self->set_values_from_config($replacer),
        );

        $set->insert_plugin($plugin_name, $plugin, after => 0, replace => 1);
    }

    method parse_extend(IllerConfiguration $set, HashRef $extender) {
        return if !$self->check_conditionals($extender);

        my $plugin_name = delete $extender->{'extend_plugin'};

        my $plugin = Dist::Iller::Configuration::Plugin->new(
                    plugin => $plugin_name,
                    parameters => $self->set_values_from_config($extender),
        );

        $set->extend_plugin($plugin_name, $plugin, remove => delete $extender->{'+remove'});
    }

    method parse_add(IllerConfiguration $set, HashRef $adder) {
        return if !$self->check_conditionals($adder);

        my $plugin_name = delete $adder->{'add_plugin'};

        my $plugin = Dist::Iller::Configuration::Plugin->new(
                    plugin => $plugin_name,
              maybe base => delete $adder->{'+base'},
                    parameters => $self->set_values_from_config($adder),
        );

        my $after = delete $adder->{'+after'};
        my $before = delete $adder->{'+before'};

        $set->insert_plugin(($after ? $after : $before), $plugin, after => ($after ? 1 : 0), replace => 0);
    }

    method parse_remove(IllerConfiguration $set, HashRef $remover) {
        return if !$self->check_conditionals($remover);

        $set->remove_plugin($remover->{'remove_plugin'});
    }

    method set_values_from_config($parameters) {
        return $parameters if !$self->has_current_config;

        foreach my $param (keys %$parameters) {
            next if $param =~ m{^\+};
            next if $parameters->{ $param } !~ m{[^.]\.[^.]};

            my($type, $what) = split /\./ => $parameters->{ $param };
            next if none { $_ eq $type } qw/$env $self/;

            if($type eq '$env' && exists $ENV{ uc $what }) {
                $parameters->{ $param } = $ENV{ uc $what };
            }
            elsif($type eq '$self' && $self->current_config->$_can($what)) {
                $parameters->{ $param } = $self->current_config->$what;
            }
        }
        return $parameters;
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
                return 0 if !$ENV{ uc $what };
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
                return 1 if $ENV{ uc $what };
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

}

1;
