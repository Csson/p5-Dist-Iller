use Dist::Iller::Standard;

class Dist::Iller::Configuration using Moose {

    has author => (
        is => 'ro',
        isa => Str,
        predicate => 1,
    );
    has license => (
        is => 'ro',
        isa => Str,
        predicate => 1,
    );
    has copyright_holder => (
        is => 'ro',
        isa => Str,
        predicate => 1,
    );
    has copyright_year => (
        is => 'ro',
        isa => Int,
        predicate => 1,
    );
    has plugins => (
        is => 'ro',
        isa => ArrayRef[IllerConfigurationPlugin],
    );
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
