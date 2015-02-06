use Dist::Iller::Standard;

# VERSION
# PODCLASSNAME

class Dist::Iller::Doctype using Moose {

    has type => (
        is => 'ro',
        isa => Enum([qw/dist weaver/]),
    );

    method dist {
        return Dist::Iller::Doctype->new(type => 'dist');
    }
    method weaver {
        return Dist::Iller::Doctype->new(type => 'weaver');
    }
}
