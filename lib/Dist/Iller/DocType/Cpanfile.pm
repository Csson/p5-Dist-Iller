use 5.10.1;
use strict;
use warnings;

package Dist::Iller::DocType::Cpanfile;

our $VERSION = '0.1403';

use Dist::Iller::Elk;
with qw/
    Dist::Iller::DocType
    Dist::Iller::Role::HasPrereqs
/;

sub comment_start { '#' }

sub filename { 'cpanfile' }

sub to_hash {
    my $self = shift;
    return { prereqs => $self->prereqs };
}

sub parse {
    my $self = shift;
    my $yaml = (shift)->{'prereqs'};

    foreach my $phase (qw/build configure develop runtime test/) {

        foreach my $relation (qw/requires recommends suggests conflicts/) {

            MODULE:
            foreach my $module (@{ $yaml->{ $phase }{ $relation } }) {
                my $module_name = ref $module eq 'HASH' ? (keys %$module)[0] : $module;
                my $version     = ref $module eq 'HASH' ? (values %$module)[0] : 0;

                $self->add_prereq(Dist::Iller::Prereq->new(
                    module => $module_name,
                    phase => $phase,
                    relation => $relation,
                    version => $version,
                ));
            }
        }
    }
    return $self;
}


sub to_string {
    my $self = shift;

    my @strings;

    for my $phase (qw/runtime test build configure develop/) {
        RELATION:
        for my $relation (qw/requires recommends suggests conflicts/) {

            my @prereqs = sort { $a->module cmp $b->module } $self->filter_prereqs(sub { $_->phase eq $phase && $_->relation eq $relation });
            next RELATION if !scalar @prereqs;

            push @strings => "on $phase => sub {";
            for my $prereq (@prereqs) {
                push @strings => sprintf q{    %s '%s' => '%s';}, $relation, $prereq->module, $prereq->version;
            }
            push @strings => '};';
        }
    }
    return join "\n" => (@strings, '');

}

__PACKAGE__->meta->make_immutable;

1;

__END__
