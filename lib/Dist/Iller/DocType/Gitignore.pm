use 5.10.0;
use strict;
use warnings;

package Dist::Iller::DocType::Gitignore;

# AUTHORITY
our $VERSION = '0.1407';

use Dist::Iller::Elk;
use Path::Tiny;
use Types::Standard qw/ArrayRef Str/;
with qw/
    Dist::Iller::DocType
/;

has always => (
    is => 'ro',
    isa => ArrayRef[Str],
    traits => ['Array'],
    default => sub { [ ] },
    handles => {
        add_always => 'push',
        all_always => 'elements',
    },
);
has onexist => (
    is => 'ro',
    isa => ArrayRef[Str],
    traits => ['Array'],
    default => sub { [ ] },
    handles => {
        add_onexists => 'push',
        all_onexists => 'elements',
    },
);

sub comment_start { '#' }

sub filename { '.gitignore' }

sub phase { 'after' }

sub to_hash {
    my $self = shift;
    return { prereqs => $self->prereqs };
}

sub parse {
    my $self = shift;
    my $yaml = shift;

    if(exists $yaml->{'always'}) {
        $self->add_always($_) for @{ $yaml->{'always'} };
    }
    if(exists $yaml->{'onexist'}) {
        $self->add_onexists($_) grep { path($_)->exists } for @{ $yaml->{'onexist'} };
    }
}

sub to_string {
    my $self = shift;

    return join "\n", ($self->all_always, $self->all_onexists, '');
}

__PACKAGE__->meta->make_immutable;

1;

__END__
