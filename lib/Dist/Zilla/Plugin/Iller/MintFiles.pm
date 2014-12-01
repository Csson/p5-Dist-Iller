package Dist::Zilla::Plugin::Iller::MintFiles;

use Moose;
extends 'Dist::Zilla::Plugin::InlineFiles';
with 'Dist::Zilla::Role::TextTemplate';

override 'merged_section_data' => sub {
    my $self = shift;

    my $data = super;

    for my $name (keys %$data) {
        $data->{ $name } = \$self->fill_in_string( ${ $data->{ $name } },
                                                   {
                                                      dist => \($self->zilla),
                                                      plugin => \($self),
                                                   },
        );
    }

    return $data;
};

1;
__DATA__
___[ Changes ]___
Revision history for {{ $dist->name }}

{{ '{{$NEXT}}' }}
   - Initial release

___[ .gitignore ]___
/{{ $dist->name }}-*
/.build
/_build*
/Build
MYMETA.*
!META.json
/.prove

___[ t/basic.t ]___
use strict;
use Test::More;
use {{ (my $mod = $dist->name) =~ s/-/::/g; $mod }};

# replace with the actual test
ok 1;

done_testing;

___[ dist.ini ]___
name = {{ (my $mod = $dist->name) =~ s/-/::/g; $mod }}
author =
license = Perl_5
copyright_holder =

[Git::GatherDir]
exclude_filename = Build.PL
exclude_filename = META.json
exclude_filename = LICENSE
exclude_filename = README.md

[CopyFilesFromBuild]
copy = META.json
copy = LICENSE
copy = Build.PL

[ReversionOnRelease]
prompt = 1

[PkgVersion]
die_on_existing_version = 1
die_on_line_insertion = 1

[NextRelease]
format = %v  %{yyyy-MM-dd HH:mm:ss VVV}d

[PreviousVersion::Changelog]
[NextVersion::Semantic]
major = API Changes
minor = New Features, Enhancements
revision = Revision, Bug Fixes, Documentation, Meta
format = %d.%03d%1d
numify_version = 0

[Git::Check]
allow_dirty = dist.ini
allow_dirty = Changes
allow_dirty = META.json
allow_dirty = README.md
allow_dirty = Build.PL

[ReadmeAnyFromPod]
filename = README.md
type = markdown
location = root

[MetaNoIndex]
directory = t
directory = xt
directory = inc
directory = share
directory = eg
directory = examples

[AutoPrereqs]

[ModuleBuildTiny]

[MetaJSON]

[ContributorsFromGit]

[Test::NoTabs]
[Test::EOL]
[Test::EOF]
[PodSyntaxTests]

[MetaYAML]

[License]

[ReadmeFromPod]

[ExtraTests]

[ExecDir]
dir = script

[ShareDir]

[Manifest]

[ManifestSkip]

[CheckChangesHasContent]

[TestRelease]

[ConfirmRelease]

;[UploadToCpan]

[Git::Commit]
commit_msg = %v
allow_dirty = dist.ini
allow_dirty = Changes
allow_dirty = META.json
allow_dirty = README.md
allow_dirty = Build.PL

[Git::Tag]
tag_format = %v
tag_message =

[Git::Push]
remotes_must_exist = 0
