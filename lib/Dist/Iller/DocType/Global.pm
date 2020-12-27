use 5.10.0;
use strict;
use warnings;

package Dist::Iller::DocType::Global;

# AUTHORITY
# ABSTRACT: Settings used in multiple other DocTypes
our $VERSION = '0.1410';

use Dist::Iller::Elk;
use Path::Tiny;
use Types::Standard qw/ArrayRef Str/;
with qw/
    Dist::Iller::DocType
/;

has distribution_name => (
    is => 'rw',
    isa => Str,
    predicate => 1,
);

sub comment_start { }

sub filename { }

sub phase { 'first' }

sub to_hash { {} }

sub parse {
    my $self = shift;
    my $yaml = shift;

    if(exists $yaml->{'distribution_name'}) {
        $self->distribution_name($yaml->{'distribution_name'});
    }
}

sub to_string { }

__PACKAGE__->meta->make_immutable;

1;

__END__
