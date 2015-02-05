use feature ':5.14';
use Moops;

# VERSION
# PODCLASSNAME

library  Dist::Iller::Types

declares IllerConfigurationPlugin

{

    class_type IllerConfiguration       => { class => 'Dist::Iller::Configuration' };
    class_type IllerConfigurationPlugin => { class => 'Dist::Iller::Configuration::Plugin' };

    coerce IllerConfigurationPlugin,
        from HashRef, via {
            my $hash = $_;

            "Dist::Iller::Configuration::Plugin"->new(%$hash);
        };
}

1;
