use feature ':5.14';
use strict;
use warnings;
use Moops;

# VERSION
# PODCLASSNAME

library  Dist::Iller::Types

declares IllerConfigurationPlugin,
         IllerConfigurationPrereq,
         ArrayRefStr

{

    class_type IllerConfiguration       => { class => 'Dist::Iller::Configuration' };
    class_type IllerConfigurationPlugin => { class => 'Dist::Iller::Configuration::Plugin' };
    class_type IllerConfigurationPrereq => { class => 'Dist::Iller::Configuration::Prereq' };
    class_type IllerDoctype             => { class => 'Dist::Iller::Doctype' };

    coerce IllerConfigurationPlugin,
        from HashRef, via {
            my $hash = $_;

            "Dist::Iller::Configuration::Plugin"->new(%$hash);
        };

    declare ArrayRefStr,
    as ArrayRef[Str];

    coerce ArrayRefStr,
    from Str,
    via { [ $_ ] };

}

1;
