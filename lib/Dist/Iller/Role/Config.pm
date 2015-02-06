use Dist::Iller::Standard;

# VERSION
# PODCLASSNAME

role Dist::Iller::Role::Config using Moose {
    requires 'filepath';

    method configlocation {
        my $package = $self->package;
        $package =~ s{::}{-}g;
        my $dir = path(dist_dir($package));
        return $dir->child($self->filepath);
    }

    method get_yaml_for(IllerDoctype $doctype) {
        return $self->get_yaml_for_dist if $doctype->type eq 'dist';
        return $self->get_yaml_for_weaver if $doctype->type eq 'weaver';
        return;
    }

    method get_yaml_for_dist {
        my $yaml = YAML::Tiny->read($self->filepath->stringify);

        return (grep { $_->{'+doctype'} eq 'dist'} @$yaml)[0];

        foreach my $document (@$yaml) {
            if($document->{'+doctype'} eq 'dist') {
                return $document;
            }
        }

    }
    method get_yaml_for_weaver {
        my $yaml = YAML::Tiny->read($self->filepath->stringify);

        return (grep { $_->{'+doctype'} eq 'weaver'} @$yaml)[0];

        foreach my $document (@$yaml) {
            if($document->{'+doctype'} eq 'dist') {
                return $document;
            }
        }

    }


}

1;
