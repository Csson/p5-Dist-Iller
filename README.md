# NAME

Dist::Iller - A Dist::Zilla & Pod::Weaver preprocessor

# VERSION

version 0.0001

# SYNOPSIS

    $ iller new -P DistIller::AMintingProvider My::Module

    $ cd My/Module

    $ iller build

# DESCRIPTION

Dist::Iller is a [Dist::Zilla](https://metacpan.org/pod/Dist::Zilla) and [Pod::Weaver](https://metacpan.org/pod/Pod::Weaver) preprocessor.

It uses one [YAML](https://metacpan.org/pod/YAML) configuration file from which it then generates `dist.ini` and `weaver.ini`:

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

This is a shortened `iller.yaml` that displays most of the functionality.

Lets walk through it:

    doctype: dist

This specifies that this yaml document will generate `dist.ini`.

    header:
      name: My-Module
      author: Ex Ample <ample@example.org>
      license: Perl_5
      copyright_holder: Ex Ample
      copyright_year: 2015

This generates the top part of `dist.ini`. `author` can be a list or string.

    prereqs:
      runtime:
        requires:
          - perl: 5.010001
          - Moose

It is possible to list all prereqs. The groups are specified in [CPAN::Meta::Spec](https://metacpan.org/pod/CPAN::Meta::Spec).

It is optional to specify the version numbers.

    plugins:
     - +plugin: DistIller::MetaGeneratedBy
     - +plugin: AutoVersion
     - +plugin: GatherDir
     - +plugin: ShareDir
       dir: myshare

List all plugins under the `plugins` key. Each item in the list is a [Dist::Zilla](https://metacpan.org/pod/Dist::Zilla) plugin. All commands for `Dist::Iller` is prepended with a `+`.

Under `ShareDir`, `dir` is a parameter for the `ShareDir` plugin. Since the keys are in different namespaces there are no collisions.

It is possible to use `Dist::Zilla::PluginBundles` by prepending `@` as usual.

    ---
    doctype: weaver

Here starts the `weaver.ini` configuration.

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

It only has a `plugins` list.

# SEE ALSO

[Dist::Zilla](https://metacpan.org/pod/Dist::Zilla)

[Pod::Weaver](https://metacpan.org/pod/Pod::Weaver)

# AUTHOR

Erik Carlsson <info@code301.com>

# COPYRIGHT AND LICENSE

This software is copyright (c) 2015 by Erik Carlsson.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
