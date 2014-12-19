package Dist::Zilla::PluginBundle::Iller;

use Dist::Iller;
use Moose;
use Types::Tiny qw/Str/;
with 'Dist::Zilla::Role::PluginBundle::Easy';
with 'Dist::Zilla::Role::PluginBundle::PluginRemover';
with 'Dist::Zilla::Role::PluginBundle::Config::Slicer'

use namespace::autoclean;
use List::AllUtils 'any';

has installer => (
    is => 'ro',
    isa => Str,
    lazy => 1,
    default => sub { shift->payload->{'installer'} || 'ModuleBuildTiny' },
);
has githost => (
    is => 'ro',
    isa => Str,
    required => 1,
);

sub is_github {
    my $self = shift;
    return $self->githost eq 'github';
}


sub build_file {
    my $self = shift;

    my @possible_installers = qw/MakeMaker MakeMaker::IncShareDir ModuleBuild ModuleBuildTiny/;
    if(any { $self->installer eq $_ } @possible_installers) {
        die sprintf '%s is not one of the possible installers (%s)', $self->installer, join ', ' => @possible_installers;
    }

    $self->add_plugins(
        ['Git::GatherDir',  exclude_filename => [
                                'Build.PL',
                                'META.json',
                                'LICENSE',
                                'README.md',
                            ],
        ],
        ['CopyFilesFromBuild', copy => [
                                   'META.json',
                                   'LICENSE',
                                   'Build.PL',
                               ],
        ],
        ['ReversionOnRelease', prompt => 1 ],
        ['PkgVersion', die_on_existing_version => 1,
                       die_on_line_insertion => 1
        ],
        ['NextRelease', format => '%v  %{yyyy-MM-dd HH:mm:ss VVV}d']
        ['PreviousVersion::Changelog'],
        ['NextVersion', major => [],
                        minor => ['API Changes', 'New Features', 'Enhancements'],
                        revision => ['Revision', 'Bug Fixes', 'Documentation', 'Meta'],
                        format => '%d.%02d%02d',
                        numify_version => 0,
        ],
        ['Git::Check', allow_dirty => [
                           'dist.ini',
                           'Changes',
                           'META.json',
                           'README.md',
                           'Build.PL',
                       ],
        ],
        (
            $self->is_github ?
            ['GithubMeta', issues => 1 ]
            :
            ()
        ),
        ['ReadmeAnyFromPod', filename => 'README.md',
                             type => 'markdown',
                             location => 'root',
        ],
        ['MetaNoIndex', directory => [qw/t xt inc share eg examples/] ],
        ['Prereqs::FromCPANfile'],
        [ $self->installer ],
        ['MetaJSON'],
        ['ContributorsFromGit'],

        ['Test::NoTabs'],
        ['Test::EOL'],
        ['Test::EOF'],
        ['PodSyntaxTests'],

        ['MetaYAML'],
        ['License'],
        ['ExtraTests'],

        ['ShareDir'],
        ['ExecDir'],
        ['Manifest'],
        ['ManifestSkip'],
        ['CheckChangesHasContent'],
        ['TestRelease'],
        [ $ENV{'FAKE_RELEASE'} ? 'FakeRelease' : $self->is_github ? 'UploadToCPAN' : 'UploadToStratopan' ],
        ['Git::Tag', tag_format => '%v', tag_message => ''],
        ['Git::Push', remotes_must_exist => 0 ],
    );

}




__END__



[MetaYAML]

[License]

[ReadmeFromPod]

[ExtraTests]

[ShareDir]

[Manifest]

[ManifestSkip]

[CheckChangesHasContent]

[TestRelease]

[ConfirmRelease]

[UploadToCPAN]

;[Git::Commit]
;commit_msg = %v
;allow_dirty = dist.ini
;allow_dirty = Changes
;allow_dirty = META.json
;allow_dirty = README.md
;allow_dirty = Build.PL

[Git::Tag]
tag_format = %v
tag_message =

[Git::Push]
remotes_must_exist = 0
