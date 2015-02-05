use Dist::Iller::Standard;

# VERSION
# PODCLASSNAME

use YAML::Tiny;
use Dist::Iller::Configuration;
use Dist::Iller::Configuration::Plugin;

class Dist::Iller::Builder using Moose with Dist::Iller::Role::ConfigBuilder {

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

    method parse() {
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

    method generate_dist_ini {

        use Data::Dump::Streamer;
        warn Dump($self->yaml)->Out;
    }

}

1;
