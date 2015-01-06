package Dist::Zilla::PluginBundle::Iller;

# VERSION

use Dist::Iller;
use Moose;
use MooseX::AttributeShortcuts;
use Types::Standard qw/Str Bool/;
with 'Dist::Zilla::Role::PluginBundle::Easy';
with 'Dist::Zilla::Role::PluginBundle::PluginRemover';
with 'Dist::Zilla::Role::PluginBundle::Config::Slicer';

use namespace::autoclean;
use List::AllUtils 'none';
use Config::INI;

has installer => (
    is => 'rw',
    isa => Str,
    lazy => 1,
    default => sub { shift->payload->{'installer'} || 'ModuleBuildTiny' },
);
has is_private => (
    is => 'rw',
    isa => Bool,
    required => 1,
    default => 0,
);
has is_task => (
    is => 'rw',
    isa => Bool,
    default => 0,
);
has weaver_config => (
    is => 'rw',
    isa => Str,
    default => '@Iller',
);
has homepage => (
    is => 'rw',
    isa => Str,
    builder => 1,
);

sub _build_homepage {
    my $distname = Config::INI::Reader->read_file('dist.ini')->{'_'}{'name'};
    return sprintf 'https://metacpan.org/release/' . $distname;
}

sub build_file {
    my $self = shift;

    return $self->installer =~ m/MakeMaker/ ? 'Makefile.PL' : 'Build.PL';
}

sub configure {
    my $self = shift;

    my @possible_installers = qw/MakeMaker MakeMaker::IncShareDir ModuleBuild ModuleBuildTiny/;
    if(none { $self->installer eq $_ } @possible_installers) {
        die sprintf '%s is not one of the possible installers (%s)', $self->installer, join ', ' => @possible_installers;
    }

    $self->add_plugins(
        ['Git::GatherDir', { exclude_filename => [
                                'META.json',
                                'LICENSE',
                                'README.md',
                                $self->build_file,
                            ] },
        ],
        ['CopyFilesFromBuild', { copy => [
                                   'META.json',
                                   'LICENSE',
                                   $self->build_file,
                               ] },
        ],
        ['PodnameFromFilename'],
        ['ReversionOnRelease', { prompt => 1 } ],
        ['OurPkgVersion'],
        ['NextRelease', { format => '%v  %{yyyy-MM-dd HH:mm:ss VVV}d' } ],
        ['PreviousVersion::Changelog'],

        ['NextVersion::Semantic', { major => '',
                                    minor => "API Changes, New Features, Enhancements",
                                    revision => "Revision, Bug Fixes, Documentation, Meta",
                                    format => '%d.%02d%02d',
                                    numify_version => 0,
                                  }
        ],
        (
            $self->is_task ?
            ['TaskWeaver']
            :
            ['PodWeaver', { config_plugin => $self->weaver_config } ]
        ),
        ['Git::Check', { allow_dirty => [
                           'dist.ini',
                           'Changes',
                           'META.json',
                           'README.md',
                           $self->build_file,
                       ] },
        ],
        (
            $self->is_private ?
            ()
            :
            ['GithubMeta', { issues => 1, homepage => $self->homepage } ]
        ),
        ['ReadmeAnyFromPod', { filename => 'README.md',
                               type => 'markdown',
                               location => 'root',
                             }
        ],
        ['MetaNoIndex', { directory => [qw/t xt inc share eg examples/] } ],
        ['Prereqs::FromCPANfile'],
        [ $self->installer ],
        ['Iller::MetaGeneratedBy'],
        ['MetaJSON'],
        ['ContributorsFromGit'],

        ['Test::NoTabs'],
        ['Test::EOL'],
        ['Test::EOF'],
        ['PodSyntaxTests'],
        ['Test::Kwalitee::Extra'],

        ['MetaYAML'],
        ['License'],
        ['ExtraTests'],

        ['ShareDir'],
        ['ExecDir'],
        ['Manifest'],
        ['ManifestSkip'],
        ['CheckChangesHasContent'],
        ['TestRelease'],
        ['ConfirmRelease'],
        [ $ENV{'FAKE_RELEASE'} ? 'FakeRelease' : $self->is_private ? 'UploadToStratopan' : 'UploadToCPAN' ],
        ['Git::Tag', { tag_format => '%v',
                       tag_message => ''
                     }
        ],
        ['Git::Push', { remotes_must_exist => 1 } ],
    );
}

1;

__END__

