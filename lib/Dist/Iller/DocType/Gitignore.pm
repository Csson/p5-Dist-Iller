use 5.10.0;
use strict;
use warnings;

package Dist::Iller::DocType::Gitignore;

# AUTHORITY
# ABSTRACT: Turn the Dist::Iller config into a .gitignore file
our $VERSION = '0.1409';

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
    return { always => $self->always, onexist => $self->onexist };
}

sub parse {
    my $self = shift;
    my $yaml = shift;

    if(exists $yaml->{'config'}) {
        # ugly hack..
        $self->parse_config({ '+config' => $yaml->{'config'} });
    }
    if(exists $yaml->{'always'}) {
        $self->add_always($_) for @{ $yaml->{'always'} };
    }
    if(exists $yaml->{'onexist'}) {
        $self->add_onexists($_) for grep { path($_)->exists } @{ $yaml->{'onexist'} };
    }
}

sub to_string {
    my $self = shift;

    return join "\n", ($self->all_always, $self->all_onexists, '');
}

__PACKAGE__->meta->make_immutable;

1;

__END__
