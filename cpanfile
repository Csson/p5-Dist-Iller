# This file was auto-generated from iller.yaml by Dist::Iller on 2016-02-18 16:11:38 UTC.

on runtime => sub {
    requires 'Carp' => '1.38';
    requires 'DateTime' => '1.05';
    requires 'Dist::Zilla' => '5.000';
    requires 'File::ShareDir' => '1.102';
    requires 'File::chdir' => '0.1010';
    requires 'JSON::MaybeXS' => '1.003003';
    requires 'List::MoreUtils' => '0.408';
    requires 'List::Util' => '1.42';
    requires 'Module::Load' => '0.26';
    requires 'Moose' => '2.1400';
    requires 'MooseX::AttributeDocumented' => '0.1003';
    requires 'MooseX::AttributeShortcuts' => '0.028';
    requires 'MooseX::StrictConstructor' => '0.19';
    requires 'Path::Tiny' => '0.072';
    requires 'PerlX::Maybe' => '1.001';
    requires 'Safe::Isa' => '1.000005';
    requires 'String::CamelCase' => '0.02';
    requires 'Text::Diff' => '1.43';
    requires 'Try::Tiny' => '0.24';
    requires 'Types::Path::Tiny' => '0.005';
    requires 'Types::Standard' => '1.000000';
    requires 'YAML::Tiny' => '1.67';
    requires 'namespace::autoclean' => '0.18';
    requires 'perl' => '5.010000';
    requires 'version' => '0.9913';
};
on test => sub {
    requires 'ExtUtils::MakeMaker' => '0';
    requires 'File::Spec' => '0';
    requires 'File::chdir' => '0.1010';
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
    requires 'Badge::Depot' => '0.0103';
    requires 'Badge::Depot::Plugin::Coverage' => '0';
    requires 'Badge::Depot::Plugin::Cpantesters' => '0';
    requires 'Badge::Depot::Plugin::Kwalitee' => '0';
    requires 'Badge::Depot::Plugin::Perl' => '0';
    requires 'Badge::Depot::Plugin::Travis' => '0';
    requires 'Dist::Zilla' => '5.000';
    requires 'Dist::Zilla::Plugin::Authority' => '1.009';
    requires 'Dist::Zilla::Plugin::BumpVersionAfterRelease::Transitional' => '0.007';
    requires 'Dist::Zilla::Plugin::ChangeStats::Dependencies::Git' => '0.0100';
    requires 'Dist::Zilla::Plugin::CheckChangesHasContent' => '0.008';
    requires 'Dist::Zilla::Plugin::Clean' => '0.07';
    requires 'Dist::Zilla::Plugin::ConfirmRelease' => '0';
    requires 'Dist::Zilla::Plugin::CopyFilesFromBuild' => '0.151680';
    requires 'Dist::Zilla::Plugin::DistIller::MetaGeneratedBy' => '0';
    requires 'Dist::Zilla::Plugin::ExecDir' => '0';
    requires 'Dist::Zilla::Plugin::Git' => '2.036';
    requires 'Dist::Zilla::Plugin::Git::Check' => '0';
    requires 'Dist::Zilla::Plugin::Git::CheckFor::CorrectBranch' => '0.013';
    requires 'Dist::Zilla::Plugin::Git::Commit' => '0';
    requires 'Dist::Zilla::Plugin::Git::Contributors' => '0.017';
    requires 'Dist::Zilla::Plugin::Git::GatherDir' => '0';
    requires 'Dist::Zilla::Plugin::Git::Push' => '0';
    requires 'Dist::Zilla::Plugin::Git::Tag' => '0';
    requires 'Dist::Zilla::Plugin::GithubMeta' => '0.54';
    requires 'Dist::Zilla::Plugin::InstallRelease' => '0.008';
    requires 'Dist::Zilla::Plugin::License' => '0';
    requires 'Dist::Zilla::Plugin::MakeMaker' => '0';
    requires 'Dist::Zilla::Plugin::Manifest' => '0';
    requires 'Dist::Zilla::Plugin::ManifestSkip' => '0';
    requires 'Dist::Zilla::Plugin::MetaJSON' => '0';
    requires 'Dist::Zilla::Plugin::MetaNoIndex' => '0';
    requires 'Dist::Zilla::Plugin::MetaProvides::Package' => '2.003001';
    requires 'Dist::Zilla::Plugin::MetaYAML' => '0';
    requires 'Dist::Zilla::Plugin::ModuleShareDirs' => '0';
    requires 'Dist::Zilla::Plugin::NextRelease::Grouped' => '0.0200';
    requires 'Dist::Zilla::Plugin::PodSyntaxTests' => '0';
    requires 'Dist::Zilla::Plugin::PodWeaver' => '4.006';
    requires 'Dist::Zilla::Plugin::Prereqs' => '0';
    requires 'Dist::Zilla::Plugin::Readme' => '0';
    requires 'Dist::Zilla::Plugin::ReadmeAnyFromPod' => '0.150250';
    requires 'Dist::Zilla::Plugin::RewriteVersion::Transitional' => '0.007';
    requires 'Dist::Zilla::Plugin::RunExtraTests' => '0.028';
    requires 'Dist::Zilla::Plugin::Test::CleanNamespaces' => '0';
    requires 'Dist::Zilla::Plugin::Test::Compile' => '2.054';
    requires 'Dist::Zilla::Plugin::Test::EOF' => '0.0501';
    requires 'Dist::Zilla::Plugin::Test::EOL' => '0.18';
    requires 'Dist::Zilla::Plugin::Test::Kwalitee::Extra' => 'v0.2.1';
    requires 'Dist::Zilla::Plugin::Test::NoTabs' => '0.15';
    requires 'Dist::Zilla::Plugin::Test::ReportPrereqs' => '0.021';
    requires 'Dist::Zilla::Plugin::Test::Version' => '1.05';
    requires 'Dist::Zilla::Plugin::TestRelease' => '0';
    requires 'Dist::Zilla::Plugin::TravisYML' => '1.15';
    requires 'Dist::Zilla::Plugin::UploadToCPAN' => '0';
    requires 'Pod::Elemental::Transformer::List' => '0';
    requires 'Pod::Weaver::Plugin::SingleEncoding' => '0';
    requires 'Pod::Weaver::Plugin::Transformer' => '0';
    requires 'Pod::Weaver::PluginBundle::CorePrep' => '0';
    requires 'Pod::Weaver::Section::Authors' => '0';
    requires 'Pod::Weaver::Section::Badges' => '0.0401';
    requires 'Pod::Weaver::Section::Collect' => '0';
    requires 'Pod::Weaver::Section::Generic' => '0';
    requires 'Pod::Weaver::Section::Homepage::DefaultCPAN' => '0.05';
    requires 'Pod::Weaver::Section::Leftovers' => '0';
    requires 'Pod::Weaver::Section::Legal' => '0';
    requires 'Pod::Weaver::Section::Name' => '0';
    requires 'Pod::Weaver::Section::Region' => '0';
    requires 'Pod::Weaver::Section::Source::DefaultGitHub' => '0.07';
    requires 'Pod::Weaver::Section::Version' => '0';
    requires 'Test::CleanNamespaces' => '0.15';
    requires 'Test::EOF' => '0';
    requires 'Test::EOL' => '0';
    requires 'Test::More' => '0.88';
    requires 'Test::NoTabs' => '1.4';
    requires 'Test::Pod' => '1.41';
    requires 'Test::Version' => '1';
    requires 'Test::Warnings' => '0.026';
};
on develop => sub {
    suggests 'Dist::Iller' => '0.1407';
    suggests 'Dist::Iller::Config::Author::CSSON' => '0.0308';
};
