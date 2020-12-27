# NAME

Dist::Iller - A Dist::Zilla & Pod::Weaver preprocessor

<div>
    <p>
    <img src="https://img.shields.io/badge/perl-5.10+-blue.svg" alt="Requires Perl 5.10+" />
    <a href="http://cpants.cpanauthors.org/release/CSSON/Dist-Iller-0.1409"><img src="http://badgedepot.code301.com/badge/kwalitee/CSSON/Dist-Iller/0.1409" alt="Distribution kwalitee" /></a>
    <a href="http://matrix.cpantesters.org/?dist=Dist-Iller%200.1409"><img src="http://badgedepot.code301.com/badge/cpantesters/Dist-Iller/0.1409" alt="CPAN Testers result" /></a>
    <img src="https://img.shields.io/badge/coverage-84.3%25-orange.svg" alt="coverage 84.3%" />
    </p>
</div>

# VERSION

Version 0.1409, released 2020-12-27.

# SYNOPSIS

    # dzil new, but...
    $ dzil new -P DistIller::AMintingProvider My::Module

    $ cd My/Module

    # ...all other commands can be used via iller
    $ iller build

# STATUS

This is alpha software. Anything can change at any time.

It is mostly here to document how I build my distributions. It is perfectly fine to use `dzil` with a distribution built with `Dist::Iller` (after a fork, for example).

# DESCRIPTION

Dist::Iller is a [Dist::Zilla](https://metacpan.org/pod/Dist::Zilla) and [Pod::Weaver](https://metacpan.org/pod/Pod::Weaver) preprocessor. It comes with a command line tool (`iller`) which is a `dzil` wrapper: When run, it first generates
files specified in `iller.yaml` in the current directory and then executes `dzil` automatically. (Since `iller` requires that an `iller.yaml` is present, `iller new ...` does not work.)

The `doctype` key in a document in `iller.yaml` matches a camelized class in the `Dist::Iller::DocType` namespace; so `doctype: dist` is parsed by [Dist::Iller::DocType::Dist](https://metacpan.org/pod/Dist::Iller::DocType::Dist).

## iller.yaml

This is the general syntax of an `iller.yaml` file:

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

## Rationale

PluginBundles for both [Dist::Zilla](https://metacpan.org/pod/Dist::Zilla) and [Pod::Weaver](https://metacpan.org/pod/Pod::Weaver) have a few downsides:

- Mixes code and configuration.
- Not straightforward to remove or replace specific plugins for a certain distribution
- Difficult to insert a plugin before another plugin for a certain distribution.
- PluginBundles can change after a distribution has been released.
- Difficult for others to understand/know which plugins actually were in effect when the distribution was built.

`Dist::Iller` tries to solve this:

- Dist::Iller configs (similar to PluginBundles) has their own `iller.yaml` (normally in `share/`) where plugins are specified. See tests and [Dist::Iller::Config::Author::CSSON](https://metacpan.org/pod/Dist::Iller::Config::Author::CSSON).
- Since `dist.ini` and `weaver.ini` are generated each time `iller` is run, the plugins listed in them are those that were used to build the distribution.
- Remove a plugin:

      - +remove_plugin: GatherDir

- Insert a plugin:

      - +add_plugin: Git::GatherDir
        +before: AutoVersion

- Replace a plugin:

      - +replace_plugin: ShareDir
        +with: ShareDir::Tarball

- Set more attributes for an already included plugin:

      - +extend_plugin: Git::GatherDir
        exclude_match:
          - examples/.*\.html

# SEE ALSO

- [Dist::Zilla](https://metacpan.org/pod/Dist::Zilla)
- [Pod::Weaver](https://metacpan.org/pod/Pod::Weaver)
- [Dist::Iller::Config::Author::CSSON](https://metacpan.org/pod/Dist::Iller::Config::Author::CSSON)

# SOURCE

[https://github.com/Csson/p5-Dist-Iller](https://github.com/Csson/p5-Dist-Iller)

# HOMEPAGE

[https://metacpan.org/release/Dist-Iller](https://metacpan.org/release/Dist-Iller)

# AUTHOR

Erik Carlsson <info@code301.com>

# COPYRIGHT AND LICENSE

This software is copyright (c) 2016 by Erik Carlsson.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
