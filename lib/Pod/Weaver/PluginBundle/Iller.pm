use 5.10.1;

package Pod::Weaver::PluginBundle::Iller;

# VERSION

use Pod::Weaver::Config::Assembler;

sub xp {
    Pod::Weaver::Config::Assembler->expand_packages(shift);
}

sub mvp_bundle_config {
    my @plugins = ();

    push @plugins => (
        ['@Iller/CorePrep',       xp('@CorePrep'),       { } ],
        ['@Iller/SingleEncoding', xp('-SingleEncoding'), { } ],
        ['@Iller/Name',           xp('Name'),            { } ],
        ['@Iller/Version',        xp('Version'),         { format => q{Version %v, released %{YYYY-MM-dd}d.} } ],
        ['@Iller/Prelude',        xp('Region'),          { region_name => 'prelude' } ],
    );

    foreach my $plugin (qw/Synopsis Description Overview Stability/) {
        push @plugins => ['@Iller/'.$plugin], xp('Generic'), { header => uc $plugin } ],
    );

    foreach my $plugin ( ['Attributes', 'attr'],
                         ['Methods', 'method'],
                         ['Functions', 'func'],
    ) {
        push @plugins => [ $plugin->[0], xp('Collect'), { command => $plugin->[1], header => uc $plugin->[0] } ]
    }

    push @plugins => (
        ['@Iller/Leftovers',             xp('Leftovers'), { } ],
        ['@Iller/postlude',              xp('Region'),    { } ],
        ['@Iller/Source::DefaultGitHub', xp('Source::DefaultGitHub') ]
        ['@Iller/Authors',               xp('Authors'),   { } ],
        ['@Iller/Legal',                 xp('Legal'),     { } ],

        ['@Iller/List', xp('-Transformer'), { transformer => 'list' } ],
        ['@Iller/', xp(''), {  } ],
        ['@Iller/', xp(''), {  } ],
    );
    return @plugins;
}

# ABSTRACT: Pod::Weaver meets Dist::Iller

