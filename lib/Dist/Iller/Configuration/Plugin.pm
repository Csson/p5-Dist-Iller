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
            delete_parameter => 'delete',
        },
    );

    method merge_with(IllerConfigurationPlugin $other_plugin) {
        foreach my $param ($other_plugin->parameter_keys) {
            if($self->get_parameter($param)) {
                if(ref $other_plugin->get_parameter($param) eq 'ARRAY') {
                    if(ref $self->get_parameter($param) eq 'ARRAY') {
                        my $new_param_data = [ uniq @{ $self->get_parameter($param) }, @{ $other_plugin->get_parameter($param) } ];
                        $self->set_parameter($param, $new_param_data);
                    }
                    else {
                        my $new_param_data = [ uniq ($self->get_parameter($param)), @{ $other_plugin->get_parameter($param) } ];
                        $self->set_parameter($param, $new_param_data);
                    }
                }
                else {
                    $self->set_parameter($param, $other_plugin->get_parameter($param));
                }
            }
            else {
                $self->set_parameter($param, $other_plugin->get_parameter($param));
            }
        }
    }

    method to_string {
        my @strings = $self->has_base ? (sprintf '[%s / %s]' => $self->base, $self->plugin)
                    :                   (sprintf '[%s]' => $self->plugin)
                    ;

        foreach my $parameter (sort $self->parameter_keys) {
            next if $parameter =~ m{^\+};
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
