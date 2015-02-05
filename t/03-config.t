use strict;
use Test::More;
use Path::Tiny;
use Dist::Iller::Builder;

use lib path('t/corpus/lib')->absolute->stringify;

ok 1;

my $builder = Dist::Iller::Builder->new(filepath => 't/corpus/03-config-iller.yaml');
$builder->parse;

done_testing;
