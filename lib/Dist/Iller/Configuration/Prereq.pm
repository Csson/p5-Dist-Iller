use Dist::Iller::Standard;

# PODCLASSNAME

class Dist::Iller::Configuration::Prereq using Moose {

    has module => (
        is => 'ro',
        isa => Str,
        required => 1,
    );
    has phase => (
        is => 'ro',
        isa => Enum[qw/build configure develop runtime test/],
        required => 1,
    );
    has relation => (
        is => 'ro',
        isa => Enum[qw/requires recommends suggests conflicts/],
        required => 1,
    );
    has version => (
        is => 'ro',
        isa => Str,
        default => '0',
    );

}
