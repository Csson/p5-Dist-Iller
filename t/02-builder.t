use strict;
use Test::More;
use Test::Differences;
use Dist::Iller;
use syntax 'qs';

my $iller = Dist::Iller->new(filepath => 't/corpus/02-builder.yaml');
$iller->parse;

eq_or_diff clean($iller->get_doc('dist')->to_string), clean(dist()), 'Correct dist.ini';
eq_or_diff clean($iller->get_doc('weaver')->to_string), clean(weaver()), 'Correct weaver.ini';

done_testing;

sub clean {
    my $string = shift;
    $string =~ s{^\v}{};
    $string =~ s{^(\s*?;.* on).*}{$1...};
    return $string;
}

sub dist {
    return qs{
        ; This file was auto-generated from iller.yaml on

        author = Erik Carlsson

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
        Dist::Zilla::Plugin::ConfirmRelease = 0
        Dist::Zilla::Plugin::ExecDir = 0
        Dist::Zilla::Plugin::ExtraTests = 0
        Dist::Zilla::Plugin::GatherDir = 0
        Dist::Zilla::Plugin::License = 0
        Dist::Zilla::Plugin::MakeMaker = 0
        Dist::Zilla::Plugin::Manifest = 0
        Dist::Zilla::Plugin::ManifestSkip = 0
        Dist::Zilla::Plugin::MetaYAML = 0
        Dist::Zilla::Plugin::PruneCruft = 0
        Dist::Zilla::Plugin::Readme = 0
        Dist::Zilla::Plugin::ShareDir = 0
        Dist::Zilla::Plugin::TestRelease = 0
        Dist::Zilla::Plugin::UploadToCPAN = 0
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

        ; authordep Dist::Zilla::Plugin::ConfirmRelease = 0
        ; authordep Dist::Zilla::Plugin::ExecDir = 0
        ; authordep Dist::Zilla::Plugin::ExtraTests = 0
        ; authordep Dist::Zilla::Plugin::GatherDir = 0
        ; authordep Dist::Zilla::Plugin::License = 0
        ; authordep Dist::Zilla::Plugin::MakeMaker = 0
        ; authordep Dist::Zilla::Plugin::Manifest = 0
        ; authordep Dist::Zilla::Plugin::ManifestSkip = 0
        ; authordep Dist::Zilla::Plugin::MetaYAML = 0
        ; authordep Dist::Zilla::Plugin::PruneCruft = 0
        ; authordep Dist::Zilla::Plugin::Readme = 0
        ; authordep Dist::Zilla::Plugin::ShareDir = 0
        ; authordep Dist::Zilla::Plugin::TestRelease = 0
        ; authordep Dist::Zilla::Plugin::UploadToCPAN = 0
        ; authordep Pod::Weaver::Plugin::SingleEncoding = 0
        ; authordep Pod::Weaver::PluginBundle::CorePrep = 0
        ; authordep Pod::Weaver::Section::Authors = 0
        ; authordep Pod::Weaver::Section::Collect = 0
        ; authordep Pod::Weaver::Section::Generic = 0
        ; authordep Pod::Weaver::Section::Leftovers = 0
        ; authordep Pod::Weaver::Section::Legal = 0
        ; authordep Pod::Weaver::Section::Name = 0
        ; authordep Pod::Weaver::Section::Region = 0
        ; authordep Pod::Weaver::Section::Version = 0
    };
}

sub weaver {
    return qs{
        ; This file was auto-generated from iller.yaml on

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
