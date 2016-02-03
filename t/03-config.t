use strict;
use Test::More;
use Test::Differences;
use Path::Tiny;
use Dist::Iller::Builder;
use syntax 'qs';

use lib 't/corpus/lib';

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
        author = Ex Ample

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
        Dist::Zilla::Plugin::ConfirmRelease = 0
        Dist::Zilla::Plugin::ExecDir = 0
        Dist::Zilla::Plugin::ExtraTests = 0
        Dist::Zilla::Plugin::GatherDir = 0
        Dist::Zilla::Plugin::LastPlugin = 0.02
        Dist::Zilla::Plugin::LicenseImproved = 0
        Dist::Zilla::Plugin::MakeMaker = 0
        Dist::Zilla::Plugin::Manifest = 0
        Dist::Zilla::Plugin::ManifestSkip = 0
        Dist::Zilla::Plugin::MetaYAML = 0
        Dist::Zilla::Plugin::PlacedAfter::ExecDir = 0
        Dist::Zilla::Plugin::PlacedBeforeExtraTests = 0
        Dist::Zilla::Plugin::PruneCruft = 0
        Dist::Zilla::Plugin::Readme = 0.01
        Dist::Zilla::Plugin::ShareDir = 0
        Dist::Zilla::Plugin::TaskWeaver = 0
        Dist::Zilla::Plugin::TestRelease = 0
        Dist::Zilla::Plugin::UploadToCPAN = 0
        Pod::Elemental::Transformer::List = 0.03
        Pod::Weaver::Plugin::SingleEncoding = 0
        Pod::Weaver::Plugin::Transformer = 0
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

        ; authordep Another::Thing = 0
        ; authordep Dist::Zilla::Plugin::ConfirmRelease = 0
        ; authordep Dist::Zilla::Plugin::ExecDir = 0
        ; authordep Dist::Zilla::Plugin::ExtraTests = 0
        ; authordep Dist::Zilla::Plugin::GatherDir = 0
        ; authordep Dist::Zilla::Plugin::LastPlugin = 0.02
        ; authordep Dist::Zilla::Plugin::LicenseImproved = 0
        ; authordep Dist::Zilla::Plugin::MakeMaker = 0
        ; authordep Dist::Zilla::Plugin::Manifest = 0
        ; authordep Dist::Zilla::Plugin::ManifestSkip = 0
        ; authordep Dist::Zilla::Plugin::MetaYAML = 0
        ; authordep Dist::Zilla::Plugin::PlacedAfter::ExecDir = 0
        ; authordep Dist::Zilla::Plugin::PlacedBeforeExtraTests = 0
        ; authordep Dist::Zilla::Plugin::PruneCruft = 0
        ; authordep Dist::Zilla::Plugin::Readme = 0.01
        ; authordep Dist::Zilla::Plugin::ShareDir = 0
        ; authordep Dist::Zilla::Plugin::TaskWeaver = 0
        ; authordep Dist::Zilla::Plugin::TestRelease = 0
        ; authordep Dist::Zilla::Plugin::UploadToCPAN = 0
        ; authordep Pod::Elemental::Transformer::List = 0.03
        ; authordep Pod::Weaver::Plugin::SingleEncoding = 0
        ; authordep Pod::Weaver::Plugin::Transformer = 0
        ; authordep Pod::Weaver::PluginBundle::CorePrep = 0
        ; authordep Pod::Weaver::Section::Authors = 0
        ; authordep Pod::Weaver::Section::Collect = 0
        ; authordep Pod::Weaver::Section::Generic = 0
        ; authordep Pod::Weaver::Section::Leftovers = 0
        ; authordep Pod::Weaver::Section::Legal = 0
        ; authordep Pod::Weaver::Section::Name = 0
        ; authordep Pod::Weaver::Section::Region = 0
        ; authordep Pod::Weaver::Section::Version = 0
        ; authordep This::Thing = 0
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

        [-Transformer / List]
        transformer = List
    };
}
