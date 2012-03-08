use strict;
use Test::More;

ok(1);
require Inline::CPP;
ok(1, 'require Inline::CPP; completed.');

{
    no warnings 'once';
    ok( defined( $Inline::CPP::grammar::TYPEMAP_KIND ), 'TYPEMAP_KIND defined.' );
}

# Test Inline::CPP::register().
subtest 'Inline::CPP::register() tests.'  => sub {
    note 'Testing Inline::CPP::register()';
    my @ALIASES = qw/ cpp C++ c++ Cplusplus cplusplus CXX cxx /;
    my $rv;
    eval { $rv = Inline::CPP::register(); };
    ok( ! $@, 'Call to Inline::CPP::register() succeeds.' );
    diag 'Failure was: ' . $@ if $@;
    is( $rv->{language}, 'CPP', 'Language CPP properly defined.' );
    is(
        scalar @{$rv->{aliases}},
        scalar @ALIASES,
        'Got proper number of aliases.'
    );
    foreach my $alias ( @ALIASES ) {
        ok(
            ( grep { $_ eq $alias } @{$rv->{aliases}} ),
            "Found alias $alias."
        );
    }
    is( $rv->{type}, 'compiled', 'Proper language type.' );
    ok(
        defined( $rv->{suffix} ),
        'An extension suffix is defined by $Config{dlext}.'
    );
    return;
};



done_testing();


