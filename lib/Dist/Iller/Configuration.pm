use Dist::Iller::Standard;

# PODCLASSNAME

class Dist::Iller::Configuration using Moose {

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
        },
    );

    method to_string {
        my @strings = ();
        push @strings => $self->author if $self->has_author;
        push @strings => $self->license if $self->has_license;
        push @strings => $self->copyright_holder if $self->has_copyright_holder;
        push @strings => $self->copyright_year if $self->has_copyright_year;

        foreach my $plugin ($self->all_plugins) {
            push @strings => $plugin->to_string;
        }

        return join "\n" => @strings;
    }
}

__END__

__document_type: dist
author:

plugins:
- config: Default

---
__document_type: weaver
plugins:
- config: Default

  - add_plugin: Test::EOL
    __before: Test::Line

  - remove_plugin: Bad::plugin
    __if: $env.removeit

- plugin: Test::EOF
