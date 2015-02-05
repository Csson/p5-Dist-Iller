use feature ':5.14';
use Moops;

# VERSION
# PODCLASSNAME

library  Dist::Iller::Types
{

    class_type IllerConfiguration       => { class => 'Dist::Iller::Configuration' };
    class_type IllerConfigurationPlugin => { class => 'Dist::Iller::Configuration::Plugin' };

}

1;
