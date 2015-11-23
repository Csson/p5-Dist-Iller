package Dist::Iller;

# VERSION

use strict;
use warnings;
use 5.14.0;

1;

# ABSTRACT: A Dist::Zilla & Pod::Weaver preprocessor

__END__

=pod

=head1 SYNOPSIS

    $ iller new -P DistIller::AMintingProvider My::Module

    $ cd My/Module

    $ iller build

=head1 STATUS

This is alpha software. Anything can change at any time.

It is mostly here to document how I build my distributions.

=head1 DESCRIPTION

Dist::Iller is a L<Dist::Zilla> and L<Pod::Weaver> preprocessor. It comes with a command line tool (C<iller>) which is a C<dzil> wrapper: When run, it first generates
C<dist.ini> and/or C<weaver.ini> from C<iller.yaml> in the current directory.

=head2 Rationale

PluginBundles for both L<Dist::Zilla> and L<Pod::Weaver> have a few downsides:

=for :list
* Mixes code and configuration
* Not straightforward to remove specific plugins for a certain distribution
* Difficult to insert specific plugins before another plugin for a certain distribution.
* PluginBundles can change after a distribution has been released.

C<Dist::Iller> tries to solve this:

=for :list
* Dist::Iller configs (similar to PluginBundles) also has a C<iller.yaml> for specifying which plugins it includes. The config module is basically only necessary
  for options (see tests and L<Dist::Iller::Config::Author::CSSON>).
* Remove a plugin:

       +remove_plugin: GatherDir

=for :list
* Insert a plugin:

       +add_plugin: Git::GatherDir
       +before: AutoVersion

=for :list
* Replace a plugin:

       +replace_plugin: ShareDir
       +With: ShareDir::Tarball

=for :list
* Since C<dist.ini> and C<weaver.ini> are generated each time C<iller> is run, the files included in the distribution are always identical to how they looked at release time.

=head2 iller.yaml

This is the general syntax of C<iller.yaml>:

    ---
    # This specifies that this yaml document will generate C<dist.ini>.
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
    # Here starts the C<weaver.ini> configuration.
    doctype: weaver

    plugins:
      # Same Dist::Iller::Config as in the 'dist' document
      - +config: My::Config

      # Use PluginBundles, but they need ''.
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

=head1 SEE ALSO

=for :list
* L<Dist::Zilla>
* L<Pod::Weaver>
* L<Dist::Iller::Config::Author::CSSON>

=cut
