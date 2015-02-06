use Dist::Iller::Standard;

# VERSION
# PODCLASSNAME

use YAML::Tiny;
use Dist::Iller::Configuration;
use Dist::Iller::Configuration::Plugin;
use Dist::Iller::Doctype;

class Dist::Iller::Builder using Moose {

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

    method parse() {
        use Data::Dump::Streamer;
        my $yaml = YAML::Tiny->read($self->filepath->stringify);
        foreach my $document (@$yaml) {
            warn '-------------------->';
            warn Dump($document)->Out;
            warn '<--------------------';
            if($document->{'+doctype'} eq 'dist') {
                next if $self->has_dist;
                $self->parse_doc($self->dist, $document);
            }
            elsif($document->{'+doctype'} eq 'weaver') {
                next if $self->has_weaver;
                $self->parse_doc($self->weaver, $document);
            }
        }
        warn $self->dist->to_string;
        warn '=======';
        warn $self->weaver->to_string;
    }

    method generate_dist_ini {

        use Data::Dump::Streamer;
        warn Dump($self->yaml)->Out;
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
            warn Dump($item)->Out;
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

        my $configobj = "Dist::Iller::Config::$config_name"->new;

        $configobj->get_yaml_for($set->doctype);
#
#        $configobj->get_dist_yaml;
#        $configobj->get_weaver_yaml;

        my $yaml = YAML::Tiny->read($configobj->filepath->stringify);

        foreach my $document (@$yaml) {
            if($document->{'+doctype'} eq $set->doctype->type) {
                delete $document->{'+doctype'};
                $self->parse_doc($set, $document);
                last;
            }
        }
    }

    method parse_plugin(IllerConfiguration $set, HashRef $plugin) {
        my $plugin_name = delete $plugin->{'plugin'};

        $set->add_plugin({
                    plugin => $plugin_name,
              maybe base => delete $plugin->{'+base'},
                    parameters => $plugin,
        });
    }

    method parse_replace(IllerConfiguration $set, HashRef $replacer) {
        return if !$self->check_conditionals($replacer);

        my $plugin_name = delete $replacer->{'replace_plugin'};
        my $replace_with = delete $replacer->{'+with'};

        my $plugin = Dist::Iller::Configuration::Plugin->new(
                    plugin => $replace_with // $plugin_name,
              maybe base => delete $replacer->{'+base'},
                    parameters => $replacer,
        );

        $set->insert_plugin($plugin_name, $plugin, after => 0, replace => 1);
    }

    method parse_extend(IllerConfiguration $set, HashRef $extender) {
        return if !$self->check_conditionals($extender);

        my $plugin_name = delete $extender->{'extend_plugin'};

        my $plugin = Dist::Iller::Configuration::Plugin->new(
                    plugin => $plugin_name,
                    parameters => $extender,
        );

        $set->extend_plugin($plugin_name, $plugin, remove => delete $extender->{'+remove'});
    }

    method parse_add(IllerConfiguration $set, HashRef $adder) {
        return if !$self->check_conditionals($adder);

        my $plugin_name = delete $adder->{'add_plugin'};

        my $plugin = Dist::Iller::Configuration::Plugin->new(
                    plugin => $plugin_name,
              maybe base => delete $adder->{'+base'},
                    parameters => $adder,
        );

        my $after = delete $adder->{'+after'};
        my $before = delete $adder->{'+before'};

        $set->insert_plugin(($after ? $after : $before), $plugin, after => ($after ? 1 : 0), replace => 0);
    }

    method parse_remove(IllerConfiguration $set, HashRef $remover) {
        return if !$self->check_conditionals($remover);

        $set->remove_plugin($remover->{'remove_plugin'});
    }

    method check_conditionals(HashRef $plugin_data) {
        if(exists $plugin_data->{'+if'} && $plugin_data->{'+if'} =~ m{[^.]\.[^.]}) {
            my($type, $what) = split /\./ => $plugin_data->{'+if'};
            if($type eq '$env') {
                return 0 if !$ENV{ uc $what };
            }
        }
        return 1;
    }

}

1;
