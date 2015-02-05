use Dist::Iller::Standard;

# VERSION
# PODCLASSNAME


role Dist::Iller::Role::ConfigBuilder using Moose {

    use Data::Dump::Streamer;

    method parse_doc(IllerConfiguration $set, HashRef $yaml) {
        foreach my $setting (qw/author license copyright_holder copyright_year/) {
            my $predicate = "has_$setting";
            if(exists $yaml->{ $setting } && !$set->$predicate) {
                $set->$setting($yaml->{'author'});
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
        }
    }

    method parse_config(IllerConfiguration $set, HashRef $config) {
        my $config_name = delete $config->{'config'};
        eval "use Dist::Iller::Config::$config_name";
        if($@) {
            die "Can't find Dist::Iller::Config::$config_name ($@) in: \n  " . join "\n  " => @INC;
        }

        my $configobj = "Dist::Iller::Config::$config_name"->new;
        my $yaml = YAML::Tiny->read($configobj->filepath->stringify);

        $self->parse_doc($set, $yaml);
        warn 'config...';
        warn Dump($yaml)->Out;
    }

    method parse_plugin(IllerConfiguration $set, HashRef $plugin) {
        my $plugin_name = delete $plugin->{'plugin'};

        $set->add_plugin({
                    plugin => $plugin_name,
              maybe base => delete $plugin->{'__base'},
                    parameters => $plugin,
        });
    }
}

1;
