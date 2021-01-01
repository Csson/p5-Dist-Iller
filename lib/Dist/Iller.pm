use 5.14.0;
use strict;
use warnings;

package Dist::Iller;

# ABSTRACT: A Dist::Zilla & Pod::Weaver preprocessor
# AUTHORITY
our $VERSION = '0.1412';

use Dist::Iller::Elk;
use Types::Standard qw/Map Str ConsumerOf/;
use Types::Path::Tiny qw/Path/;
use String::CamelCase qw/camelize/;
use Try::Tiny;
use Carp qw/croak/;
use Module::Load qw/load/;
use Safe::Isa qw/$_does/;
use YAML::Tiny;
use Dist::Iller::Prereq;

has docs => (
    is => 'ro',
    isa => Map[Str, ConsumerOf['Dist::Iller::DocType'] ],
    default => sub { +{ } },
    traits => ['Hash'],
    handles => {
        set_doc => 'set',
        get_doc => 'get',
        doc_keys => 'keys',
        doc_kv => 'kv',
    },
);
has filepath => (
    is => 'ro',
    isa => Path,
    default => 'iller.yaml',
    coerce => 1,
);

sub parse {
    my $self = shift;
    my $phase = shift;

    my $yaml = YAML::Tiny->read($self->filepath->stringify);

    DOCTYPE:
    for my $document (sort { $a->{'doctype'} cmp $b->{'doctype'} } @{ $yaml }) {
        my $doctype_class = sprintf 'Dist::Iller::DocType::%s', camelize($document->{'doctype'});
        try {
            load $doctype_class;
        }
        catch {
            croak "Can't load $doctype_class: $_";
        };
        next DOCTYPE if $doctype_class->phase ne $phase;
        $self->set_doc($document->{'doctype'}, $doctype_class->new(global => $self->get_doc('global'))->parse($document));
    }
    if($self->get_doc('dist')) {
        $self->get_doc('dist')->add_prereq(Dist::Iller::Prereq->new(
            module => __PACKAGE__,
            version => __PACKAGE__->VERSION,
            phase => 'develop',
            relation => 'suggests',
        ));

        DOC:
        for my $doc ($self->doc_kv) {
            if($doc->[1]->$_does('Dist::Iller::Role::HasPlugins')) {
                $self->get_doc('dist')->add_plugins_as_prereqs($doc->[1]->packages_for_plugin, $doc->[1]->all_plugins);
            }

            for my $included_config ($doc->[1]->all_included_configs) {
                $self->get_doc('dist')->add_prereq(Dist::Iller::Prereq->new(
                    module => $included_config->[0],
                    version => $included_config->[1],
                    phase => 'develop',
                    relation => 'suggests',
                ));
            }

            next DOC if $doc->[0] eq 'dist';
            next DOC if $doc->[0] eq 'cpanfile';
            if($doc->[1]->$_does('Dist::Iller::Role::HasPrereqs')) {
                $self->get_doc('dist')->merge_prereqs($doc->[1]->all_prereqs);
            }
        }
    }
    if($self->get_doc('cpanfile') && $self->get_doc('dist')) {
        $self->get_doc('cpanfile')->merge_prereqs($self->get_doc('dist')->all_prereqs);
    }
}

sub generate_files {
    my $self = shift;
    my $phase = shift;

    croak q{'phase' must be either 'before' or 'after'} if !defined $phase || $phase ne 'before' && $phase ne 'after';

    for my $doc ($self->doc_kv) {
        next if $doc->[1]->phase ne $phase;
        $doc->[1]->generate_file;
    }
}

__PACKAGE__->meta->make_immutable;

1;

__END__

=pod

=head1 SYNOPSIS

    # dzil new, but...
    $ dzil new -P DistIller::AMintingProvider My::Module

    $ cd My/Module

    # ...all other commands can be used via iller
    $ iller build

=head1 STATUS

This is alpha software. Anything can change at any time.

It is mostly here to document how I build my distributions. It is perfectly fine to use C<dzil> with a distribution built with C<Dist::Iller> (after a fork, for example).

=head1 DESCRIPTION

Dist::Iller is a L<Dist::Zilla> and L<Pod::Weaver> preprocessor. It comes with a command line tool (C<iller>) which is a C<dzil> wrapper: When run, it first generates
files specified in C<iller.yaml> in the current directory and then executes C<dzil> automatically. (Since C<iller> requires that an C<iller.yaml> is present, C<iller new ...> does not work.)

The C<doctype> key in a document in C<iller.yaml> matches a camelized class in the C<Dist::Iller::DocType> namespace; so C<doctype: dist> is parsed by L<Dist::Iller::DocType::Dist>.

=head2 iller.yaml

This is the general syntax of an C<iller.yaml> file:

    ---
    # This specifies that this yaml document will generate dist.ini.
    doctype: dist

    # This generates the top part of C<dist.ini>. C<author> can be a list or string.
    header:
      name: My-Module
      author: Ex Ample <ample@example.org>
      license: Perl_5
      copyright_holder: Ex Ample
      copyright_year: 2015

    # It is possible to list all prereqs. The groups are specified in CPAN::Meta::Spec.
    # Minimum version numbers are optional.
    prereqs:
      runtime:
        requires:
          - perl: 5.010001
          - Moose

    # List all plugins under the 'plugins' key.
    # Each +plugin item is a Dist::Zilla> plugin.
    # All commands for Dist::Iller is prepended with a +.
    plugins:
      # Includes all plugins specified in Dist::Iller::Config::My::Config
      - +config: My::Config

      - +plugin: DistIller::MetaGeneratedBy
      - +plugin: AutoVersion
      - +plugin: GatherDir

      # 'dir' is a parameter for ShareDir
      - +plugin: ShareDir
        dir: myshare

    [...]

    ---
    # Here starts the weaver.ini configuration.
    doctype: weaver

    plugins:
      # Same Dist::Iller::Config as in the 'dist' document
      - +config: My::Config

      # Use PluginBundles
      - +plugin: '@CorePrep'

      - +plugin: -SingleEncoding

      - +plugin: Name

      - +plugin: Version
        format: Version %v, released %{YYYY-MM-dd}d.

      - +plugin: prelude
        +base:  Region

      - +plugin: List
        +base: -Transformer
        +in: Elemental
        transformer: List

    [...]

    ---
    # Here starts the .gitignore configuration
    doctype: gitignore

    always:
      - /.build
      - /_build*
      - /Build
      - MYMETA.*
      - '!META.json'
      - /.prove
    ---
    # No configuration for .cpanfile, but by having a YAML document for it, it gets generated from
    # the prereqs listed in the 'dist' document
    doctype: cpanfile

=head2 Rationale

PluginBundles for both L<Dist::Zilla> and L<Pod::Weaver> have a few downsides:

=for :list
* Mixes code and configuration.
* Not straightforward to remove or replace specific plugins for a certain distribution
* Difficult to insert a plugin before another plugin for a certain distribution.
* PluginBundles can change after a distribution has been released.
* Difficult for others to understand/know which plugins actually were in effect when the distribution was built.

C<Dist::Iller> tries to solve this:

=for :list
* Dist::Iller configs (similar to PluginBundles) has their own C<iller.yaml> (normally in C<share/>) where plugins are specified. See tests and L<Dist::Iller::Config::Author::CSSON>.
* Since C<dist.ini> and C<weaver.ini> are generated each time C<iller> is run, the plugins listed in them are those that were used to build the distribution.
* Remove a plugin:

      - +remove_plugin: GatherDir

=for :list
* Insert a plugin:

      - +add_plugin: Git::GatherDir
        +before: AutoVersion

=for :list
* Replace a plugin:

      - +replace_plugin: ShareDir
        +with: ShareDir::Tarball

=for :list
* Set more attributes for an already included plugin:

      - +extend_plugin: Git::GatherDir
        exclude_match:
          - examples/.*\.html

=head1 SEE ALSO

=for :list
* L<Dist::Zilla>
* L<Pod::Weaver>
* L<Dist::Iller::Config::Author::CSSON>

=cut
