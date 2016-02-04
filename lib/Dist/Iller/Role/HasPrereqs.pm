use 5.10.1;
use strict;
use warnings;

package Dist::Iller::Role::HasPrereqs;

use Moose::Role;
use version;
use Types::Standard qw/ArrayRef InstanceOf/;
use Dist::Iller::Prereq;

has prereqs => (
    is => 'ro',
    isa => ArrayRef[InstanceOf['Dist::Iller::Prereq']],
    traits => ['Array'],
    handles => {
        add_prereq => 'push',
        filter_prereqs => 'grep',
        find_prereq => 'first',
        get_prereq => 'get',
        all_prereqs => 'elements',
    },
);

# Ensure that we require the highest wanted version
around add_prereq => sub {
    my $next = shift;
    my $self = shift;
    my $prereq = shift;

    my $already_existing = $self->find_prereq(sub {$_->module eq $prereq->module && $_->phase eq $prereq->phase });

    if($already_existing) {
        my $old_version = version->parse($already_existing->version);
        my $new_version = version->parse($prereq->version);

        if($new_version > $old_version) {
            $already_existing->version($prereq->version);
        }
    }
    else {
        $self->$next($prereq);
    }
};

sub merge_prereqs {
    my $self = shift;
    my @prereqs = @_;

    for my $prereq (@prereqs) {
        my $already_existing = $self->find_prereq(sub {$_->module eq $prereq->module && $_->phase eq $prereq->phase });

        if($already_existing) {
            my $old_version = version->parse($already_existing->version);
            my $new_version = version->parse($prereq->version);

            if($new_version > $old_version) {
                $already_existing->version($prereq->version);
            }
        }
        else {
            $self->add_prereq($prereq);
        }
    }
}

sub prereqs_to_hash {
    my $self = shift;

    my $hash = {};
    for my $prereq ($self->all_prereqs) {
        if(!exists $hash->{ $prereq->phase }{ $prereq->relation }) {
            $hash->{ $prereq->phase }{ $prereq->relation } = [];
        }
        push @{ $hash->{ $prereq->phase }{ $prereq->relation } } => { $prereq->module => $prereq->version };
    }
    return $hash;
}

1;

__END__
