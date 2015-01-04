package Dist::Iller;

# VERSION

use strict;
use 5.10.1;

1;

__END__

=encoding utf-8

=head1 NAME

Dist::Iller - Another way to use Dist::Zilla

=head1 SYNOPSIS

  iller new Dist::Name

=head1 DESCRIPTION

Dist::Iller is a L<Dist::Zilla> profile, minter and L<plugin bundle|Dist::Zilĺa::PluginBundle::Iller>.

This was inspired by L<Dist::Milla>, which is recommended if you are looking for a straight-forward way to start using L<Dist::Zilla>.

The reason for not just releasing the plugin bundle is the C<iller> command. Together with the profile it initializes a git repository, runs C<dzil build> on it, and then adds the newly created files to the repo. I find that useful.

=head1 SEE ALSO

L<Dist::Zilla>

L<Dist::Milla>

=head1 AUTHOR

Erik Carlsson E<lt>info@code301.comE<gt>

=head1 COPYRIGHT

Copyright 2015 - Erik Carlsson

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
