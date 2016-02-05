use 5.10.1;
use strict;
use warnings;

package Dist::Iller::DocType::Dist;

# VERSION

use Dist::Iller::Elk;
with qw/
    Dist::Iller::DocType
    Dist::Iller::Role::HasPrereqs
    Dist::Iller::Role::HasPlugins
/;

use Types::Standard qw/HashRef ArrayRef Str Int/;
use PerlX::Maybe qw/maybe provided/;

has name => (
    is => 'rw',
    isa => Str,
    predicate => 1,
    init_arg => undef,
);
has author => (
    is => 'rw',
    isa => (ArrayRef[Str])->plus_coercions(Str, sub { [$_] }),
    init_arg => undef,
    traits => ['Array'],
    default => sub { [ ] },
    coerce => 1,
    handles => {
        all_authors => 'elements',
        map_authors => 'map',
        add_author => 'push',
        has_author => 'count',
    },
);
has license => (
    is => 'rw',
    isa => Str,
    predicate => 1,
    init_arg => undef,
);
has copyright_holder => (
    is => 'rw',
    isa => Str,
    predicate => 1,
    init_arg => undef,
);
has copyright_year => (
    is => 'rw',
    isa => Int,
    predicate => 1,
    init_arg => undef,
);

sub filename { 'dist.ini' }

sub comment_start { ';' }

sub parse {
    my $self = shift;
    my $yaml = shift;
    $self->parse_header($yaml->{'header'});
    $self->parse_prereqs($yaml->{'prereqs'});
    $self->parse_plugins($yaml->{'plugins'});
    return $self;
}

around qw/parse_header parse_prereqs/ => sub {
    my $next = shift;
    my $self = shift;
    my $yaml = shift;

    return if !defined $yaml;
    $self->$next($yaml);
};

sub parse_header {
    my $self = shift;
    my $yaml = shift;

    foreach my $setting (qw/name author license copyright_holder copyright_year/) {
        my $value = $yaml->{ $setting };
        my $predicate = "has_$setting";

        if(!$self->$predicate && $value) {
            $self->$setting($value);
        }
    }
}

sub parse_prereqs {
    my $self = shift;
    my $yaml = shift;

    foreach my $phase (qw/build configure develop runtime test/) {

        foreach my $relation (qw/requires recommends suggests conflicts/) {

            MODULE:
            foreach my $module (@{ $yaml->{ $phase }{ $relation } }) {
                my $module_name = ref $module eq 'HASH' ? (keys %$module)[0] : $module;
                my $version     = ref $module eq 'HASH' ? (values %$module)[0] : 0;

                $self->add_prereq(Dist::Iller::Prereq->new(
                    module => $module_name,
                    phase => $phase,
                    relation => $relation,
                    version => $version,
                ));
            }
        }
    }
}

# to_hash does not translate prereqs into [Prereqs / *Phase*Requires] plugins
sub to_hash {
    my $self = shift;

    my $header = {
        provided $self->has_author, author => $self->author,
                              maybe name => $self->name,
                              maybe license => $self->license,
                              maybe copyright_holder => $self->copyright_holder,
                              maybe copyright_year => $self->copyright_year,

    };
    my $hash = {
        header => $header,
        prereqs => $self->prereqs_to_hash,
        plugins => $self->plugins_to_hash,
    };
    return $hash;
}

sub packages_for_plugin {
    return sub {
        my $plugin = shift;

        my $name = $plugin->has_base ? $plugin->base : $plugin->plugin_name;
        $name =~ m{^(.)};
        my $first = $1;

        my $clean_name = $name;
        $clean_name =~ s{^[-%=@]}{};

        my $packages = [];
        push @{ $packages } => $first eq '%' ? { version => $plugin->version, package => sprintf 'Dist::Zilla::Stash::%s', $clean_name }
                            :  $first eq '@' ? { version => $plugin->version, package => sprintf 'Dist::Zilla::PluginBundle::%s', $clean_name }
                            :  $first eq '=' ? { version => $plugin->version, package => sprintf $clean_name }
                            :                  { version => $plugin->version, package => sprintf 'Dist::Zilla::Plugin::%s', $clean_name }
                            ;
        return $packages;
    };
}

sub add_plugins_as_prereqs {
    my $self = shift;
    my $packages_for_plugin = shift;
    my @plugins = @_;

    for my $plugin (@plugins) {
        my $packages = $packages_for_plugin->($plugin);

        for my $package (@{ $packages }) {
            $self->add_prereq(Dist::Iller::Prereq->new(
                module => $package->{'package'},
                phase => 'develop',
                relation => 'requires',
                version => $package->{'version'},
            ));
        }
    }
}

sub to_string {
    my $self = shift;

    for my $phase (qw/build configure develop runtime test/) {
        RELATION:
        for my $relation (qw/requires recommends suggests conflicts/) {

            my $plugin_name = sprintf '%s%s', ucfirst $phase, ucfirst $relation;

            # in case to_string is called twice, don't add this again
            next RELATION if $self->find_plugin(sub { $_->plugin_name eq $plugin_name });

            my @prereqs = $self->filter_prereqs(sub { $_->phase eq $phase && $_->relation eq $relation });
            next RELATION if !scalar @prereqs;

            $self->add_plugin({
                plugin_name => $plugin_name,
                base => 'Prereqs',
                parameters => { map { $_->module => $_->version } @prereqs },
            });
        }
    }

    my @strings = ();
    push @strings => sprintf 'name = %s', $self->name if $self->name;

    if($self->has_author) {
        push @strings => $self->map_authors(sub { qq{author = $_} });
    }
    push @strings => sprintf 'license = %s', $self->license if $self->has_license;
    push @strings => sprintf 'copyright_holder = %s', $self->copyright_holder if $self->has_copyright_holder;
    push @strings => sprintf 'copyright_year = %s', $self->copyright_year if $self->has_copyright_year;
    push @strings => '' if scalar @strings;

    foreach my $plugin ($self->all_plugins) {
        push @strings => $plugin->to_string, '';
    }

    {
        my $has_author_deps = 0;
        my $previous_module = '';

        AUTHORDEP:
        foreach my $authordep (sort { $a->module cmp $b->module } $self->filter_prereqs(sub { $_->relation eq 'requires' && $_->module ne 'perl' && $_->phase eq 'develop' })) {
            next AUTHORDEP if $authordep->module eq $previous_module;
            push @strings => sprintf '; authordep %s = %s', $authordep->module, $authordep->version;
            $has_author_deps = 1;
            $previous_module = $authordep->module;
        }
        push @strings => '' if $has_author_deps;
    }

    return join "\n" => @strings;

}

__PACKAGE__->meta->make_immutable;

1;

__END__
