use Dist::Iller::Standard;

# PODCLASSNAME

class Dist::Iller::Configuration::Plugin using Moose {

    has plugin => (
        is => 'ro',
        isa => Str,
    );
    has base => (
        is => 'ro',
        isa => Str,
        predicate => 1,
    );
    has parameters => (
        is => 'ro',
        isa => HashRef,
        traits => [qw/Hash/],
        handles => {
            set_parameter => 'set',
            get_parameter => 'get',
            parameter_keys => 'keys',
        },
    );

    method to_string {
        my @strings = $self->has_base ? (sprintf '[%s / %s]' => $self->base, $self->plugin)
                    :                   (sprintf '[%s]' => $self->plugin)
                    ;

        foreach my $parameter (sort $self->parameter_keys) {
            my $value = $self->get_parameter($parameter);

            if(ref $value eq 'ARRAY') {
                foreach my $val (sort @$value) {
                    push @strings => sprintf '%s = %s', $parameter, $val;
                }
            }
            else {
                push @strings => sprintf '%s = %s', $parameter, $value;
            }
        }

        return join "\n" => '', @strings;
    }
}
