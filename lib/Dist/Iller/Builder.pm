use Dist::Iller::Standard;

# VERSION
# PODCLASSNAME

use YAML::Tiny;

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

        foreach my $document (YAML::Tiny->read($self->filepath->stringify)) {
            if(delete $document->{'__doctype'} eq 'dist') {
                next if $self->has_dist;
                $self->parse_doc($self->dist, $document);
            }
            elsif(delete $document->{'__doctype'} eq 'weaver') {
                next if $self->has_weaver;
                $self->parse_doc($self->weaver, $document);
            }
        }
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
        foreach my $plugin (@$plugins) {
            $self->parse_plugin($set, $plugin) if exists $plugin->{'plugin'};
        }
    }

    method generate_dist_ini {

        use Data::Dump::Streamer;
        warn Dump($self->yaml)->Out;
    }

}

1;
