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
    has authordeps => (
        is => 'rw',
        isa => ArrayRef[Str],
        default => sub { [] },
        traits => [qw/Array/],
        handles => {
            has_authordeps => 'count',
            all_authordeps => 'elements',
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

            if($current_plugin->plugin eq $plugin_name) {
                my @all_plugins = $self->all_plugins;
                splice @all_plugins, ($after ? $index + 1 : $index), ($replace ? 1 : 0), $new_plugin;
                $self->plugins(\@all_plugins);

                if($replace) {
                    say "[DI] Replaced [$plugin_name]";
                }
                else {
                    say sprintf "[DI] Inserted [%s] %s [%s]", $new_plugin->plugin, ($after ? 'after' : 'before'), $current_plugin->plugin;
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

            if($current_plugin->plugin eq $plugin_name) {
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

            if($current_plugin->plugin eq $remove_name) {
                my @all_plugins = $self->all_plugins;
                splice @all_plugins, $index, 1;
                $self->plugins(\@all_plugins);
                say "[DI] Removed [$remove_name]";
                last;
            }
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
        if($self->has_authordeps) {
            push @strings => map { "; authordep $_" } $self->all_authordeps;
            push @strings => '';
        }

        foreach my $plugin ($self->all_plugins) {
            push @strings => $plugin->to_string, '';
        }

        return join "\n" => @strings;
    }
}

__END__
