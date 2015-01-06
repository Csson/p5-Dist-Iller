# NAME

Dist::Iller - Another way to use Dist::Zilla

# VERSION

version 0.1002

# SYNOPSIS

    iller new Dist::Name

# DESCRIPTION

Dist::Iller is a [Dist::Zilla](https://metacpan.org/pod/Dist::Zilla) profile, minter, [Dist::Zilla plugin bundle](https://metacpan.org/pod/Dist::Zilla::PluginBundle::Iller), and [Pod::Weaver plugin bundle](https://metacpan.org/pod/Pod::Weaver::PluginBundle::Iller).

This was inspired by [Dist::Milla](https://metacpan.org/pod/Dist::Milla), which is recommended if you are looking for a straight-forward way to start using [Dist::Zilla](https://metacpan.org/pod/Dist::Zilla).

The reason for not just releasing the plugin bundles is the `iller` command. Together with the profile it initializes a git repository, runs `dzil build` on it, and then adds the newly created files to the repo. I find that useful.

# SEE ALSO

[Dist::Zilla](https://metacpan.org/pod/Dist::Zilla)

[Dist::Milla](https://metacpan.org/pod/Dist::Milla)

[Pod::Weaver](https://metacpan.org/pod/Pod::Weaver)

# AUTHOR

Erik Carlsson <info@code301.com>

# COPYRIGHT AND LICENSE

This software is copyright (c) 2015 by Erik Carlsson.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
