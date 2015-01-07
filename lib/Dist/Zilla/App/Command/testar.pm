use strict;
use warnings;
package Dist::Zilla::App::Command::testar;
# ABSTRACT: test your dist
$Dist::Zilla::App::Command::testar::VERSION = '5.030';
use Dist::Zilla::App -command;
 
#pod =head1 SYNOPSIS
#pod
#pod   dzil test [ --release ] [ --no-author ] [ --automated ] [ --all ]
#pod
#pod =head1 DESCRIPTION
#pod
#pod This command is a thin wrapper around the L<test|Dist::Zilla::Dist::Builder/test> method in
#pod Dist::Zilla.  It builds your dist and runs the tests with the AUTHOR_TESTING
#pod environment variable turned on, so it's like doing this:
#pod
#pod   export AUTHOR_TESTING=1
#pod   dzil build --no-tgz
#pod   cd $BUILD_DIRECTORY
#pod   perl Makefile.PL
#pod   make
#pod   make test
#pod
#pod A build that fails tests will be left behind for analysis, and F<dzil> will
#pod exit a non-zero value.  If the tests are successful, the build directory will
#pod be removed and F<dzil> will exit with status 0.
#pod
#pod =cut
 
sub opt_spec {
  [ 'release'   => 'enables the RELEASE_TESTING env variable', { default => 0 } ],
  [ 'automated' => 'enables the AUTOMATED_TESTING env variable', { default => 0 } ],
  [ 'author!' => 'enables the AUTHOR_TESTING env variable (default behavior)', { default => 1 } ],
  [ 'all' => 'enables the RELEASE_TESTING, AUTOMATED_TESTING and AUTHOR_TESTING env variables', { default => 0 } ],
  [ 'keep-build-dir|keep' => 'keep the build directory even after a success' ],
  [ 'jobs|j=i' => 'number of parallel test jobs to run' ],
}
 
#pod =head1 OPTIONS
#pod
#pod =head2 --release
#pod
#pod This will run the test suite with RELEASE_TESTING=1
#pod
#pod =head2 --automated
#pod
#pod This will run the test suite with AUTOMATED_TESTING=1
#pod
#pod =head2 --no-author
#pod
#pod This will run the test suite without setting AUTHOR_TESTING
#pod
#pod =head2 --all
#pod
#pod Equivalent to --release --automated --author
#pod
#pod =cut
 
sub abstract { 'test your dist' }
 
sub execute {
  my ($self, $opt, $arg) = @_;
  
  local $ENV{'ILLER_AUTHOR_TEST'} = 1;
  local $ENV{RELEASE_TESTING} = 1;
  local $ENV{AUTHOR_TESTING} = 1;
  local $ENV{AUTOMATED_TESTING} = 1 if $opt->automated or $opt->all;
 
  $self->zilla->test({
    $opt->keep_build_dir
      ? (keep_build_dir => 1)
      : (),
    $opt->jobs
      ? (jobs => $opt->jobs)
      : (),
  });
}
 
1;
 
__END__
