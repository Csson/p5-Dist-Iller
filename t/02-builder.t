use strict;
use Test::More;
use Test::Differences;
use Dist::Iller::Builder;
use syntax 'qs';

ok 1;

my $builder = Dist::Iller::Builder->new(filepath => 't/corpus/02-builder.yaml');
$builder->parse;

eq_or_diff $builder->dist->to_string, clean(dist()), 'Correct dist.ini';
eq_or_diff $builder->weaver->to_string, clean(weaver()), 'Correct dist.ini';

done_testing;

sub clean {
    my $string = shift;
    $string =~ s{^\v}{};
    return $string;
}

sub dist {
    return qs{
        ; authordep Moose

        [GatherDir]

        [PruneCruft]

        [ManifestSkip]

        [MetaYAML]

        [License]

        [Readme]

        [ExtraTests]

        [ExecDir]

        [ShareDir]

        [MakeMaker]

        [Manifest]

        [TestRelease]

        [ConfirmRelease]

        [UploadToCPAN]
    };
}

sub weaver {
    return qs{
        [@CorePrep]

        [-SingleEncoding]

        [Name]

        [Version]

        [Region / prelude]

        [Generic / Synopsis]

        [Generic / Description]

        [Generic / Overview]

        [Collect / Attributes]
        command = attr
        header = ATTRIBUTES

        [Collect / Methods]
        command = method
        header = METHODS

        [Collect / Functions]
        command = func
        header = FUNCTIONS

        [Leftovers]

        [Region / postlude]

        [Authors]

        [Legal]
    };
}
