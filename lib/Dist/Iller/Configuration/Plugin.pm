use Dist::Iller::Standard;

class Dist::Iller::Configuration::Name using Moose {

	has name => (
	    is => 'ro',
	    isa => Str,
	);
	has base => (
	    is => 'ro',
	    isa => Str,
	);
	
	
	
}
