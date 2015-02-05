use Dist::Iller::Standard;

class Dist::Iller::Config::DistIllerTestConfig using Moose with Dist::Iller::Role::Config {

    has filepath => (
        is => 'ro',
        isa => Path,
        default => 't/corpus/03-config-config.yaml',
        coerce => 1,
    );

    method package {
        return __PACKAGE__;
    }
}

1;
