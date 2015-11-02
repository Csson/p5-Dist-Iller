use 5.10.1;
use strict;
use warnings;

package Dist::Iller::App;

# VERSION
# ABSTRACT: Wraps dzil with a dist.ini and weaver.ini generator

use parent 'Dist::Zilla::App';
use Dist::Iller::Builder;

sub _default_command_base { 'Dist::Zilla::App::Command' }

sub prepare_command {
    my $self = shift;
    my($cmd, $opt, @args) = $self->SUPER::prepare_command(@_);

    # No-op when creating dist.
    if(!$cmd->isa('Dist::Zilla::App::Command::new')) {
        my $builder = Dist::Iller::Builder->new->parse;
        $builder->generate_dist_ini if defined $builder;
        $builder->generate_weaver_ini if defined $builder;
    }

    return $cmd, $opt, @args;
}
sub execute_command {
    my $self = shift;
    $self->SUPER::execute_command(@_);

}

1;
