use Dist::Iller::Standard;

# VERSION
# PODCLASSNAME

role Dist::Iller::Role::Config using Moose {
    use File::ShareDir 'dist_dir';

    requires 'filepath';
    has distribution_name => (
        is => 'ro',
        isa => Str,
    );

    method configlocation {
        my $package = $self->package;
        $package =~ s{::}{-}g;
        my $dir = path('.');
        try {
            $dir = path(dist_dir($package));
        }
        finally { };
        return $dir->child($self->filepath);
    }

    method get_yaml_for(IllerDoctype $doctype) {
        return $self->get_yaml_for_dist if $doctype->type eq 'dist';
        return $self->get_yaml_for_weaver if $doctype->type eq 'weaver';
        return;
    }

    method get_yaml_for_dist {
        my $yaml = YAML::Tiny->read($self->configlocation->absolute->stringify);

        return (grep { $_->{'+doctype'} eq 'dist'} @$yaml)[0];
    }
    method get_yaml_for_weaver {
        my $yaml = YAML::Tiny->read($self->configlocation->stringify);

        return (grep { $_->{'+doctype'} eq 'weaver'} @$yaml)[0];
    }
    # sharedir skulle kunna vara en tanke.


}

1;
