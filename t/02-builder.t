use strict;
use Test::More;
use Dist::Iller::Builder;

ok 1;

my $builder = Dist::Iller::Builder->new(filepath => 't/corpus/02-builder.yaml');
$builder->parse;

done_testing;
