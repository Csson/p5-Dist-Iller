package Dist::Iller;

# VERSION

use strict;
use warnings;
use 5.10.1;

1;

# ABSTRACT: Another way to use Dist::Zilla

__END__

=pod

=head1 SYNOPSIS

  iller new Dist::Name

=head1 DESCRIPTION

Dist::Iller is a L<Dist::Zilla> profile, minter, L<Dist::Zilla plugin bundle|Dist::Zilla::PluginBundle::Iller>, and L<Pod::Weaver plugin bundle|Pod::Weaver::PluginBundle::Iller>.

This was inspired by L<Dist::Milla>, which is recommended if you are looking for a straight-forward way to start using L<Dist::Zilla>.

The reason for not just releasing the plugin bundles is the C<iller> command. Together with the profile it initializes a git repository, runs C<dzil build> on it, and then adds the newly created files to the repo. I find that useful.

=head1 SEE ALSO

L<Dist::Zilla>

L<Dist::Milla>

L<Pod::Weaver>

=cut
