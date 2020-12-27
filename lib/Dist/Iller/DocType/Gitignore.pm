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

for my $setting (qw/always onexist/) {
    has $setting => (
        is => 'ro',
        isa => ArrayRef[Str],
        traits => ['Array'],
        default => sub { [ ] },
        handles => {
            "add_$setting" => 'push',
            "all_$setting" => 'elements',
            "get_$setting" => 'get',
            "set_$setting" => 'set',
        },
    );
}

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
        $self->add_onexist($_) for grep { path($_)->exists } @{ $yaml->{'onexist'} };
    }

    if ($self->global && $self->global->has_distribution_name) {
        for my $type (qw/always onexist/) {
            my $all = "all_$type";
            my $get = "get_$type";
            my $set = "set_$type";
            for my $index (0.. scalar $self->$all - 1) {
                my $item = $self->$get($index);
                $self->$set($index, '/'.$self->global->distribution_name.'-*') if $item eq '$self.distribution_name';
            }
        }
    }
}

sub to_string {
    my $self = shift;

    return join "\n", ($self->all_always, $self->all_onexist, '');
}

__PACKAGE__->meta->make_immutable;

1;

__END__
