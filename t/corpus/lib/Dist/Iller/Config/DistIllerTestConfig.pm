use Dist::Iller::Standard;

class Dist::Iller::Config::DistIllerTestConfig using Moose {

	has filepath => (
	    is => 'ro',
	    isa => Str,
	    default => 't/corpus/03-config-config.yaml',
	);
	
}
