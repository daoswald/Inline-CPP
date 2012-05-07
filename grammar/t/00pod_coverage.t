use strict;
use warnings;
use Test::More;

# Satisfy CPANTS, even though all functions are internal.

eval "use Test::Pod::Coverage 1.00";  ## no critic (eval)
plan skip_all => "Test::Pod::Coverage 1.00 required for testing POD coverage"
    if $@;


# Test for Inline::grammar.

# There really aren't any functions explicitly called by the user. Everything
# is for internal use, and doesn't require POD documentation.
my $trustme = {
    trustme => [
        qr/(?:
              ^_
            | grammar       # Inline::CPP::grammar internal functions.
            | handle
            | strip
            | typemap
        )/x
    ]
};

pod_coverage_ok( 'Inline::CPP::grammar', $trustme );


done_testing();
