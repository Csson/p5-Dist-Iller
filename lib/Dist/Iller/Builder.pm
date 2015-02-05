use Dist::Iller::Standard;

# VERSION
# PODCLASSNAME

use YAML::Tiny;
use Dist::Iller::Configuration;
use Dist::Iller::Configuration::Plugin;

class Dist::Iller::Builder using Moose {

    has dist => (
        is => 'ro',
        init_arg => undef,
        lazy => 1,
        predicate => 1,
        isa => IllerConfiguration,
        default => sub { Dist::Iller::Configuration->new },
    );
    has weaver => (
        is => 'ro',
        init_arg => undef,
        lazy => 1,
        predicate => 1,
        isa => IllerConfiguration,
        default => sub { Dist::Iller::Configuration->new },
    );
    has filepath => (
        is => 'ro',
        isa => Path,
        default => 'iller.yaml',
        coerce => 1,
    );

    #has yaml => (
    #    is => 'ro',
    #    isa => Any,
    #    init_arg => undef,
    #);

    #around BUILDARGS {
    #    my $orig = shift;
    #    my $class = shift;
    #
    #    $class->$orig(yaml => );
    #}

    method parse {
        use Data::Dump::Streamer;
        my $yaml = YAML::Tiny->read($self->filepath->stringify);
        foreach my $document (@$yaml) {
            warn '-------------------->';
            warn Dump($document)->Out;
            warn '<--------------------';
            if($document->{'__doctype'} eq 'dist') {
                next if $self->has_dist;
                $self->parse_doc($self->dist, $document);
            }
            elsif($document->{'__doctype'} eq 'weaver') {
                next if $self->has_weaver;
                $self->parse_doc($self->weaver, $document);
            }
        }
        warn $self->dist->to_string;
        warn '=======';
        warn $self->weaver->to_string;
    }

    method parse_doc($set, $yaml) {
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

    method parse_plugins($set, $plugins) {
        foreach my $item (@$plugins) {
            $self->parse_plugin($set, $item) if exists $item->{'plugin'};
        }
    }

    method parse_plugin($set, HashRef $plugin) {
        my $plugin_name = delete $plugin->{'plugin'};

        $set->add_plugin({
            plugin => $plugin_name,
      maybe base => delete $plugin->{'__base'},
            parameters => $plugin,
        });
    }

    method generate_dist_ini {

        use Data::Dump::Streamer;
        warn Dump($self->yaml)->Out;
    }

}

1;
