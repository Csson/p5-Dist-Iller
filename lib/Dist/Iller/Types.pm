use 5.10.1;
use strict;
use warnings;

package Dist::Iller::Types;

# VERSION

use Type::Library
    -base,
    -declare => qw/
        IllerConfigurationPlugin
        IllerConfigurationPrereq
        ArrayRefStr
/;
use Type::Utils -all;
use Types::Standard qw/HashRef ArrayRef Str/;

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

1;

__END__
