use Dist::Iller::Standard;

class Dist::Iller::Doctype using Moose {

	has type => (
	    is => 'ro',
	    isa => Enum(qw/dist weaver/),
	);
	

	classmethod dist {
		return Dist::Iller::Doctype->new(type => 'dist');
	}
	classmethod weaver {
		return Dist::Iller::Doctype->new(type => 'weaver');
	}
}
