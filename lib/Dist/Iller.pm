package Dist::Iller;

# VERSION

use strict;
use warnings;
use 5.10.1;

1;

# ABSTRACT: A Dist::Zilla & Pod::Weaver preprocessor

__END__

=pod

=head1 SYNOPSIS

    $ iller new -P DistIller::AMintingProvider My::Module

    $ cd My/Module

    $ iller build


=head1 DESCRIPTION

Dist::Iller is a L<Dist::Zilla> and L<Pod::Weaver> preprocessor.

It uses one L<YAML> configuration file from which it then generates C<dist.ini> and C<weaver.ini>:

    ---
    doctype: dist

    header:
      name: My-Module
      author: Ex Ample <ample@example.org>
      license: Perl_5
      copyright_holder: Ex Ample
      copyright_year: 2015

    prereqs:
      runtime:
        requires:
          - perl: 5.010001
          - Moose

    plugins:
     - +plugin: DistIller::MetaGeneratedBy
     - +plugin: AutoVersion
     - +plugin: GatherDir
     - +plugin: ShareDir
       dir: myshare

    [...]

    ---
    doctype: weaver

    plugins:
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

This is a shortened C<iller.yaml> that displays most of the functionality.

Lets walk through it:

    doctype: dist

This specifies that this yaml document will generate C<dist.ini>.

    header:
      name: My-Module
      author: Ex Ample <ample@example.org>
      license: Perl_5
      copyright_holder: Ex Ample
      copyright_year: 2015

This generates the top part of C<dist.ini>. C<author> can be a list or string.

    prereqs:
      runtime:
        requires:
          - perl: 5.010001
          - Moose

It is possible to list all prereqs. The groups are specified in L<CPAN::Meta::Spec>.

It is optional to specify the version numbers.

    plugins:
     - +plugin: DistIller::MetaGeneratedBy
     - +plugin: AutoVersion
     - +plugin: GatherDir
     - +plugin: ShareDir
       dir: myshare

List all plugins under the C<plugins> key. Each item in the list is a L<Dist::Zilla> plugin. All commands for C<Dist::Iller> is prepended with a C<+>.

Under C<ShareDir>, C<dir> is a parameter for the C<ShareDir> plugin. Since the keys are in different namespaces there are no collisions.

It is possible to use C<Dist::Zilla::PluginBundles> by prepending C<@> as usual.

    ---
    doctype: weaver

Here starts the C<weaver.ini> configuration.

    plugins:
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

It only has a C<plugins> list.

=head1 SEE ALSO

L<Dist::Zilla>

L<Dist::Milla>

L<Pod::Weaver>

L<Dist::Zilla::PluginBundle::Author::CSSON>

L<Pod::Weaver::PluginBundle::Author::CSSON>

=cut
