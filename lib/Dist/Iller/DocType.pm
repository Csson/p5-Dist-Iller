use 5.10.1;
use strict;
use warnings;

package Dist::Iller::DocType;

use Moose::Role;
use MooseX::AttributeShortcuts;
use Try::Tiny;
use Types::Standard -types;
use Module::Load qw/load/;
use String::CamelCase qw/decamelize/;
use YAML::Tiny;
use Carp qw/croak/;
use DateTime;

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
        ...
        # recurse
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

        my $configobj = $config_class->new(%{ $yaml }); # ? -> maybe distribution_name => $set->name);
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

1;

__END__