use strict;
use Test::More;
use Test::Differences;
use Path::Tiny;
use Dist::Iller::Builder;
use syntax 'qs';

use lib path('t/corpus/lib')->absolute->stringify;

ok 1;

my $builder = Dist::Iller::Builder->new(filepath => 't/corpus/03-config-iller.yaml');
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
        author = Erik Carlsson

        [GatherDir]

        [PruneCruft]

        [ManifestSkip]

        [TaskWeaver]

        [MetaYAML]

        [LicenseImproved]
        license = perl_5

        [Readme]
        headings = head1
        headings = head2
        more_root = no
        suffix = md

        [PlacedBeforeExtraTests]

        [ExtraTests]

        [ExecDir]
        dir = bin

        [PlacedAfter::ExecDir]

        [ShareDir]

        [MakeMaker]

        [Manifest]

        [TestRelease]

        [ConfirmRelease]
        default = $self.confirm_release
        prompt = $

        [UploadToCPAN]

        [LastPlugin]
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
