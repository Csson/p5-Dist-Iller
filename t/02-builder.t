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

        [Prereqs / DevelopRequires]
        Pod::Weaver::Plugin::SingleEncoding = 0
        Pod::Weaver::PluginBundle::CorePrep = 0
        Pod::Weaver::Section::Authors = 0
        Pod::Weaver::Section::Collect = 0
        Pod::Weaver::Section::Generic = 0
        Pod::Weaver::Section::Leftovers = 0
        Pod::Weaver::Section::Legal = 0
        Pod::Weaver::Section::Name = 0
        Pod::Weaver::Section::Region = 0
        Pod::Weaver::Section::Version = 0

        [Prereqs / RuntimeRequires]
        Moose = 0

        ; authordep Moose
        ; authordep Pod::Weaver::PluginBundle::CorePrep
        ; authordep Pod::Weaver::Plugin::SingleEncoding
        ; authordep Pod::Weaver::Section::Name
        ; authordep Pod::Weaver::Section::Version
        ; authordep Pod::Weaver::Section::Region
        ; authordep Pod::Weaver::Section::Generic
        ; authordep Pod::Weaver::Section::Collect
        ; authordep Pod::Weaver::Section::Leftovers
        ; authordep Pod::Weaver::Section::Authors
        ; authordep Pod::Weaver::Section::Legal
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
