# NAME

Dist::Iller - Another way to use Dist::Zilla

# SYNOPSIS

    iller new Dist::Name

# DESCRIPTION

Dist::Iller is a [Dist::Zilla](https://metacpan.org/pod/Dist::Zilla) profile, minter and [plugin bundle](https://metacpan.org/pod/Dist::Zilĺa::PluginBundle::Iller).

This was inspired by [Dist::Milla](https://metacpan.org/pod/Dist::Milla), which is recommended if you are looking for a straight-forward way to start using [Dist::Zilla](https://metacpan.org/pod/Dist::Zilla).

The reason for not just releasing the plugin bundle is the `iller` command. Together with the profile it initializes a git repository, runs `dzil build` on it, and then adds the newly created files to the repo. I find that useful.

# SEE ALSO

[Dist::Zilla](https://metacpan.org/pod/Dist::Zilla)

[Dist::Milla](https://metacpan.org/pod/Dist::Milla)

# AUTHOR

Erik Carlsson <info@code301.com>

# COPYRIGHT

Copyright 2015 - Erik Carlsson

# LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.
