use Dist::Iller::Standard;

# VERSION
# PODCLASSNAME

role Dist::Iller::Role::Config using Moose {
    requires 'filepath';
    use Data::Dump::Streamer;

    method configdir {
        my $package = $self->package;
        $package =~ s{::}{-}g;
        return path(dist_dir($package));
    }
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
        warn "\n\n     IN THE CONFIG \n \n" . Dump($yaml)->Out;
        warn '!!!--------------------!!!';

        foreach my $document (@$yaml) {
            if($document->{'+doctype'} eq 'dist') {
                return $self->run_modifications($document);
            }
        }

    }

    method run_modifications(HashRef $yaml) {
        return 1;
    }

}

1;
