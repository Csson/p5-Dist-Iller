use Dist::Iller::Standard;

# VERSION
# PODCLASSNAME

role Dist::Iller::Role::Config using Moose {
    requires 'filepath';

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

}

1;
