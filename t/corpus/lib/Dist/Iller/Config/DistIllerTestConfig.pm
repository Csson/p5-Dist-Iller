use Dist::Iller::Standard;

class Dist::Iller::Config::DistIllerTestConfig using Moose with Dist::Iller::Role::Config {

    use YAML::Tiny;

    has filepath => (
        is => 'ro',
        isa => Path,
        default => 't/corpus/03-config-config.yaml',
        coerce => 1,
    );

    has no_manifest_skip => (
        is => 'ro',
        isa => Bool,
        default => 0,
    );
    has prompt => (
        is => 'ro',
        isa => Str,
        default => '>',
    );
    

    has is_task => (
        is => 'ro',
        isa => Bool,
        default => 0,
    );

    method package {
        return __PACKAGE__;
    }

}

1;
