use 5.10.1;
use strict;
use warnings;

package Dist::Iller::DocType;

# VERSION

use Moose::Role;
use MooseX::AttributeShortcuts;
use namespace::autoclean;
use Try::Tiny;
use Types::Standard qw/ConsumerOf Str HashRef/;
use Module::Load qw/load/;
use String::CamelCase qw/decamelize/;
use YAML::Tiny;
use Carp qw/croak/;
use DateTime;
use Path::Tiny;
use Safe::Isa qw/$_can/;
use Types::Path::Tiny qw/Path/;
use PerlX::Maybe qw/maybe/;

requires qw/
    filename
    parse
    to_hash
    to_string
    comment_start
/;

# this is set if we are parsing a ::Config class
has config_obj => (
    is => 'ro',
    isa => ConsumerOf['Dist::Iller::Config'],
    predicate =>1,
);
has doctype => (
    is => 'ro',
    isa => Str,
    init_arg => undef,
    default => sub { decamelize( (split /::/, shift->meta->name)[-1] ); },
);
has included_configs => (
    is => 'ro',
    isa => HashRef,
    init_arg => undef,
    traits => ['Hash'],
    default => sub { +{ } },
    handles => {
        set_included_config => 'set',
        all_included_configs => 'kv',
        has_included_configs => 'count',
    },
);

before parse => sub {
    my $self = shift;
    my $yaml = shift;

    $self->parse_config($yaml->{'configs'});
};
sub parse_config {
    my $self = shift;
    my $yaml = shift;

    return if !defined $yaml;

    if(ref $yaml eq 'ARRAY') {
        warn 'Multiple configs found';
        for my $doc (@{ $yaml }) {
            $self->parse_config($doc);
        }
    }
    else {
        my $config_name = delete $yaml->{'+config'};
        my $config_class = "Dist::Iller::Config::$config_name";

        try {
            load "$config_class";
        }
        catch {
            croak "Can't find $config_class ($_)";
        };

        my $configobj = $config_class->new(%{ $yaml }, maybe distribution_name => ($self->$_can('name') ? $self->name : undef));
        my $configdoc = $configobj->get_yaml_for($self->doctype);
        return if !defined $configdoc;

        $self->parse($configdoc);
        $self->set_included_config($config_class, $config_class->VERSION);
    }
}

sub to_yaml { YAML::Tiny->new(shift->to_hash)->[0] }

around to_string => sub {
    my $next = shift;
    my $self = shift;

    my $string = $self->$next(@_);
    return $string if !defined $self->comment_start;

    my $now = DateTime->now;

    my @intro = ();
    push @intro => $self->comment_start . sprintf (' This file was auto-generated from iller.yaml on %s %s %s.', $now->ymd, $now->hms, $now->time_zone->name);
    if($self->has_included_configs) {
        push @intro => $self->comment_start . ' The follow configs were used:';

        for my $config (sort { $a->[0] cmp $b->[0] } $self->all_included_configs) {
            push @intro => $self->comment_start . qq{ * $config->[0]: $config->[1]};
        }
    }
    push @intro => ('', '');

    return join ("\n", @intro) . $string;

};

sub generate_file {
    my $self = shift;
    my $path = Path->check($self->filename) ? $self->filename : Path->coerce($self->filename);

    my $new_document = $self->prepare_for_compare($self->to_string);
    my $previous_document = $self->prepare_for_compare($path->exists ? $path->slurp_utf8 : undef);

    if(!defined $previous_document) {
        say "[Iller] Creates $path";
        $path->spew_utf8($self->to_string);
    }
    elsif($new_document ne $previous_document) {
        say "[Iller] Generates $path";
        $path->spew_utf8($self->to_string);
    }
    else {
        say "[Iller] No changes for $path";
    }
}

sub prepare_for_compare {
    my $self = shift;
    my $contents = shift;

    return if !defined $contents;

    my $comment_start = $self->comment_start;
    $contents =~ s{^$comment_start .*(?=\v)}{}xg;
    $contents =~ s{\v+}{\n}g;

    return $contents;
}

1;

__END__