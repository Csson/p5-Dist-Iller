use Dist::Iller::Standard;

class Dist::Iller::Config::DistIllerTestConfig using Moose {

    with 'Dist::Iller::Role::Config';

    has +filepath => (
        default => 't/corpus/03-config-config.yaml',
    );

    method package {
        return __PACKAGE__;
    }
}
