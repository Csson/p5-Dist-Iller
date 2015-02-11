use Dist::Iller::Standard;

# PODCLASSNAME

class Dist::Iller::Configuration using Moose {

    has doctype => (
        is => 'ro',
        isa => IllerDoctype,
    );
    has name => (
        is => 'rw',
        isa => Str,
        predicate => 1,
    );
    has author => (
        is => 'rw',
        isa => Str,
        predicate => 1,
    );
    has license => (
        is => 'rw',
        isa => Str,
        predicate => 1,
    );
    has copyright_holder => (
        is => 'rw',
        isa => Str,
        predicate => 1,
    );
    has copyright_year => (
        is => 'rw',
        isa => Int,
        predicate => 1,
    );
    has prereqs => (
        is => 'ro',
        isa => ArrayRef,
        traits => ['Array'],
        handles => {
            add_prereq => 'push',
            filter_prereqs => 'grep',
            get_prereq => 'get',
        },
    );
    has plugins => (
        is => 'rw',
        isa => ArrayRef[IllerConfigurationPlugin],
        traits => [qw/Array/],
        default => sub { [] },
        coerce => 1,
        handles => {
            add_plugin => 'push',
            all_plugins => 'elements',
            filter_plugins => 'grep',
            find_plugin => 'first',
            count_plugins => 'count',
            get_plugin => 'get',
        },
    );

    method insert_plugin(Str $plugin_name, IllerConfigurationPlugin $new_plugin, Bool :$after = 0, Bool :$replace = 0) {

        foreach my $index (0 .. $self->count_plugins - 1) {
            my $current_plugin = $self->get_plugin($index);

            if($current_plugin->plugin_name eq $plugin_name) {
                my @all_plugins = $self->all_plugins;
                splice @all_plugins, ($after ? $index + 1 : $index), ($replace ? 1 : 0), $new_plugin;
                $self->plugins(\@all_plugins);

                if($replace) {
                    say "[DI] Replaced [$plugin_name]";
                }
                else {
                    say sprintf "[DI] Inserted [%s] %s [%s]", $new_plugin->plugin_name, ($after ? 'after' : 'before'), $current_plugin->plugin_name;
                }
                last;
            }
        }
    }

    method extend_plugin(Str $plugin_name, IllerConfigurationPlugin $new_plugin, :$remove) {

        $remove = defined $remove ? ref $remove eq 'ARRAY' ? $remove
                                                           : [ $remove ]
                :                                            []
                ;
        say sprintf '[DI] From %s remove %s', $plugin_name, join ', ' => @$remove if scalar @$remove;

        foreach my $index (0 .. $self->count_plugins - 1) {
            my $current_plugin = $self->get_plugin($index);

            if($current_plugin->plugin_name eq $plugin_name) {
                foreach my $param_to_remove (@$remove) {
                    $current_plugin->delete_parameter($param_to_remove);
                }
                $current_plugin->merge_with($new_plugin);
                last;
            }
        }
    }

    method remove_plugin(Str $remove_name) {
        foreach my $index (0 .. $self->count_plugins - 1) {
            my $current_plugin = $self->get_plugin($index);

            if($current_plugin->plugin_name eq $remove_name) {
                my @all_plugins = $self->all_plugins;
                splice @all_plugins, $index, 1;
                $self->plugins(\@all_plugins);
                say "[DI] Removed [$remove_name]";
                last;
            }
        }
    }

    method add_prereq_plugins {

        foreach my $phase (qw/build configure develop runtime test/) {
            RELATION:
            foreach my $relation (qw/requires recommends suggests conflicts/) {

                my @prereqs = $self->filter_prereqs(sub { $_->phase eq $phase && $_->relation eq $relation });
                next RELATION if !scalar @prereqs;

                my $plugin_name = sprintf '%s%s', ucfirst $phase, ucfirst $relation;
                $self->add_plugin({
                    plugin_name => $plugin_name,
                    base => 'Prereqs',
                    parameters => { map { $_->module => $_->version } @prereqs },
                });
            }
        }
    }

    method add_prereqs_from_configuration(IllerConfiguration $other_config) {

        foreach my $plugin ($other_config->all_plugins) {

            $self->add_prereq(Dist::Iller::Configuration::Prereq->new(
                module => join ('::' => $other_config->doctype->namespace, $plugin->plugin_package_ending),
                version => 0,
                phase => 'develop',
                relation => 'requires',
            ));
        }
    }

    method to_string {

        my @strings = ();
        push @strings => sprintf 'name = %s', $self->name if $self->name;
        push @strings => sprintf 'author = %s', $self->author if $self->has_author;
        push @strings => sprintf 'license = %s', $self->license if $self->has_license;
        push @strings => sprintf 'copyright_holder = %s', $self->copyright_holder if $self->has_copyright_holder;
        push @strings => sprintf 'copyright_year = %s', $self->copyright_year if $self->has_copyright_year;
        push @strings => '' if scalar @strings;

        foreach my $plugin ($self->all_plugins) {
            push @strings => $plugin->to_string, '';
        }
        my $had_author_deps = 0;
        foreach my $authordep_module (uniq map { $_->module } $self->filter_prereqs(sub { $_->relation eq 'requires' && $_->module ne 'perl' })) {
            push @strings => sprintf '; authordep %s', $authordep_module;
            ++$had_author_deps;
        }
        push @strings => '' if $had_author_deps;


        return join "\n" => @strings;
    }
}

__END__
