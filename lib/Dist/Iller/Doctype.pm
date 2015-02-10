use Dist::Iller::Standard;

# VERSION
# PODCLASSNAME

class Dist::Iller::Doctype using Moose {

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

    method _build_headers {
        return [qw/name author license copyright_holder copyright_year/] if $self->type eq 'dist';
        return [];
    }

    method dist {
        return Dist::Iller::Doctype->new(type => 'dist');
    }
    method weaver {
        return Dist::Iller::Doctype->new(type => 'weaver');
    }
}
