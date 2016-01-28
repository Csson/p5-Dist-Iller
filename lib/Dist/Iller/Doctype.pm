use 5.10.1;
use strict;
use warnings;

package Dist::Iller::Doctype;

# VERSION

use Dist::Iller::Elk;
use namespace::autoclean;
use MooseX::AttributeShortcuts;
use Types::Standard qw/Enum ArrayRef/;

has type => (
    is => 'ro',
    isa => Enum([qw/dist weaver/]),
);
has headers => (
    is => 'ro',
    isa => ArrayRef,
    traits => ['Array'],
    lazy => 1,
    builder => 1,
    handles => {
        all_headers => 'elements',
    }
);

sub _build_headers {
    my $self = shift;
    return [qw/name author license copyright_holder copyright_year/] if $self->type eq 'dist';
    return [];
}
sub namespace {
    my $self = shift;
    return 'Dist::Zilla' if $self->type eq 'dist';
    return 'Pod::Weaver' if $self->type eq 'weaver';
}

sub dist {
    my $self = shift;
    return Dist::Iller::Doctype->new(type => 'dist');
}
sub weaver {
    my $self = shift;
    return Dist::Iller::Doctype->new(type => 'weaver');
}
sub is_weaver {
    my $self = shift;
    return $self->type eq 'weaver' ? 1 : 0;
}
sub is_dist {
    my $self = shift;
    return $self->type eq 'dist' ? 1 : 0;
}

__PACKAGE__->meta->make_immutable;

1;

__END__
