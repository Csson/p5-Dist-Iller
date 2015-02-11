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

        [Prereqs / DevelopRequires]
        Another::Thing = 0
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
        This::Thing = 0

        ; authordep Another::Thing
        ; authordep This::Thing
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
