use 5.14.0;
use strict;
use warnings;


package Dist::Iller::Standard {

    # VERSION

    use base 'Moops';
    use List::AllUtils();
    use Dist::Iller::Types();
    use Path::Tiny;
    use Types::Path::Tiny();
    use MooseX::AttributeDocumented();
    use MooseX::AttributeShortcuts();
    use PerlX::Maybe();

    sub import {
        my $class = shift;
        my %opts = @_;

        push @{ $opts{'imports'} ||= [] } => (
            'List::AllUtils'    => [qw/any none sum uniq/],
            'PerlX::Maybe'      => [qw/maybe/],
            'feature'           => [qw/:5.14/],
            'Path::Tiny'        => [],
            'Types::Path::Tiny'  => [{ replace => 1 }, '-types'],
            'Dist::Iller::Types' => [{ replace => 1 }, '-types'],
            'MooseX::AttributeDocumented' => [],
            'MooseX::AttributeShortcuts' => [],
        );

        $class->SUPER::import(%opts);
    }
}

1;
