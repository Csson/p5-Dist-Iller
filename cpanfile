# This file was auto-generated from iller.yaml by Dist::Iller on 2016-02-17 23:33:31 UTC.

on runtime => sub {
    requires 'Carp' => '0';
    requires 'DateTime' => '0';
    requires 'Dist::Zilla' => '5.000';
    requires 'File::ShareDir' => '0';
    requires 'File::chdir' => '0';
    requires 'JSON::MaybeXS' => '0';
    requires 'List::MoreUtils' => '0';
    requires 'List::Util' => '0';
    requires 'Module::Load' => '0';
    requires 'Moose' => '2.1400';
    requires 'MooseX::AttributeDocumented' => '0';
    requires 'MooseX::AttributeShortcuts' => '0';
    requires 'MooseX::StrictConstructor' => '0';
    requires 'Path::Tiny' => '0';
    requires 'PerlX::Maybe' => '0';
    requires 'Safe::Isa' => '0';
    requires 'String::CamelCase' => '0.02';
    requires 'Text::Diff' => '1.43';
    requires 'Try::Tiny' => '0';
    requires 'Types::Path::Tiny' => '0';
    requires 'Types::Standard' => '1.000000';
    requires 'YAML::Tiny' => '0';
    requires 'namespace::autoclean' => '0.18';
    requires 'perl' => '5.010000';
    requires 'version' => '0';
};
on test => sub {
    requires 'ExtUtils::MakeMaker' => '0';
    requires 'File::Spec' => '0';
    requires 'File::chdir' => '0';
    requires 'IO::Handle' => '0';
    requires 'IPC::Open3' => '0';
    requires 'Syntax::Feature::Qi' => '0';
    requires 'Syntax::Feature::Qs' => '0';
    requires 'Test::Differences' => '0';
    requires 'Test::More' => '0.96';
    requires 'syntax' => '0';
};
on test => sub {
    recommends 'CPAN::Meta' => '2.120900';
};
on configure => sub {
    requires 'ExtUtils::MakeMaker' => '0';
    requires 'File::ShareDir::Install' => '0.06';
};
on develop => sub {
    requires 'Badge::Depot' => '0';
    requires 'Badge::Depot::Plugin::Coverage' => '0';
    requires 'Badge::Depot::Plugin::Cpantesters' => '0';
    requires 'Badge::Depot::Plugin::Kwalitee' => '0';
    requires 'Badge::Depot::Plugin::Perl' => '0';
    requires 'Badge::Depot::Plugin::Travis' => '0';
    requires 'Dist::Zilla::Plugin::Authority' => '1.009';
    requires 'Dist::Zilla::Plugin::BumpVersionAfterRelease::Transitional' => '0.007';
    requires 'Dist::Zilla::Plugin::ChangeStats::Dependencies::Git' => '0';
    requires 'Dist::Zilla::Plugin::CheckChangesHasContent' => '0';
    requires 'Dist::Zilla::Plugin::Clean' => '0';
    requires 'Dist::Zilla::Plugin::ConfirmRelease' => '0';
    requires 'Dist::Zilla::Plugin::CopyFilesFromBuild' => '0';
    requires 'Dist::Zilla::Plugin::DistIller::MetaGeneratedBy' => '0';
    requires 'Dist::Zilla::Plugin::ExecDir' => '0';
    requires 'Dist::Zilla::Plugin::Git::Check' => '0';
    requires 'Dist::Zilla::Plugin::Git::CheckFor::CorrectBranch' => '0.013';
    requires 'Dist::Zilla::Plugin::Git::Commit' => '0';
    requires 'Dist::Zilla::Plugin::Git::Contributors' => '0';
    requires 'Dist::Zilla::Plugin::Git::GatherDir' => '0';
    requires 'Dist::Zilla::Plugin::Git::Push' => '0';
    requires 'Dist::Zilla::Plugin::Git::Tag' => '0';
    requires 'Dist::Zilla::Plugin::GithubMeta' => '0';
    requires 'Dist::Zilla::Plugin::InstallRelease' => '0';
    requires 'Dist::Zilla::Plugin::License' => '0';
    requires 'Dist::Zilla::Plugin::MakeMaker' => '0';
    requires 'Dist::Zilla::Plugin::Manifest' => '0';
    requires 'Dist::Zilla::Plugin::ManifestSkip' => '0';
    requires 'Dist::Zilla::Plugin::MetaJSON' => '0';
    requires 'Dist::Zilla::Plugin::MetaNoIndex' => '0';
    requires 'Dist::Zilla::Plugin::MetaProvides::Class' => '0';
    requires 'Dist::Zilla::Plugin::MetaProvides::Package' => '0';
    requires 'Dist::Zilla::Plugin::MetaYAML' => '0';
    requires 'Dist::Zilla::Plugin::ModuleShareDirs' => '0';
    requires 'Dist::Zilla::Plugin::NextRelease::Grouped' => '0';
    requires 'Dist::Zilla::Plugin::PodSyntaxTests' => '0';
    requires 'Dist::Zilla::Plugin::PodWeaver' => '0';
    requires 'Dist::Zilla::Plugin::PodnameFromClassname' => '0';
    requires 'Dist::Zilla::Plugin::Prereqs' => '0';
    requires 'Dist::Zilla::Plugin::Prereqs::Plugins' => '0';
    requires 'Dist::Zilla::Plugin::Readme' => '0';
    requires 'Dist::Zilla::Plugin::ReadmeAnyFromPod' => '0';
    requires 'Dist::Zilla::Plugin::RewriteVersion::Transitional' => '0.007';
    requires 'Dist::Zilla::Plugin::RunExtraTests' => '0';
    requires 'Dist::Zilla::Plugin::Test::CleanNamespaces' => '0';
    requires 'Dist::Zilla::Plugin::Test::Compile' => '0';
    requires 'Dist::Zilla::Plugin::Test::EOF' => '0';
    requires 'Dist::Zilla::Plugin::Test::EOL' => '0';
    requires 'Dist::Zilla::Plugin::Test::Kwalitee::Extra' => '0';
    requires 'Dist::Zilla::Plugin::Test::NoTabs' => '0';
    requires 'Dist::Zilla::Plugin::Test::ReportPrereqs' => '0';
    requires 'Dist::Zilla::Plugin::Test::Version' => '0';
    requires 'Dist::Zilla::Plugin::TestRelease' => '0';
    requires 'Dist::Zilla::Plugin::TravisYML' => '0';
    requires 'Dist::Zilla::Plugin::UploadToCPAN' => '0';
    requires 'Pod::Elemental::Transformer::List' => '0';
    requires 'Pod::Weaver::Plugin::SingleEncoding' => '0';
    requires 'Pod::Weaver::Plugin::Transformer' => '0';
    requires 'Pod::Weaver::PluginBundle::CorePrep' => '0';
    requires 'Pod::Weaver::Section::Authors' => '0';
    requires 'Pod::Weaver::Section::Badges' => '0.0401';
    requires 'Pod::Weaver::Section::Collect' => '0';
    requires 'Pod::Weaver::Section::Generic' => '0';
    requires 'Pod::Weaver::Section::Homepage::DefaultCPAN' => '0';
    requires 'Pod::Weaver::Section::Leftovers' => '0';
    requires 'Pod::Weaver::Section::Legal' => '0';
    requires 'Pod::Weaver::Section::Name' => '0';
    requires 'Pod::Weaver::Section::Region' => '0';
    requires 'Pod::Weaver::Section::Source::DefaultGitHub' => '0';
    requires 'Pod::Weaver::Section::Version' => '0';
    requires 'Test::CleanNamespaces' => '0.15';
    requires 'Test::EOL' => '0';
    requires 'Test::More' => '0.88';
    requires 'Test::NoTabs' => '0';
    requires 'Test::Pod' => '1.41';
    requires 'Test::Warnings' => '0';
};
on develop => sub {
    suggests 'Dist::Iller' => '0.1406';
    suggests 'Dist::Iller::Config::Author::CSSON' => '0.0307';
};