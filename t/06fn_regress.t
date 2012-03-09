use strict;
use Test::More;

note( 'Regression tests for CPP.pm to assure refactoring breaks nothing.' );

require Inline::CPP;

{
    no warnings 'once';
    ok( defined( $Inline::CPP::grammar::TYPEMAP_KIND ), 'TYPEMAP_KIND defined.' );
}

# Test Inline::CPP::register().
subtest 'Inline::CPP::register() tests.'  => sub {
    note 'Testing Inline::CPP::register()';
    plan tests => 12;
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


# Test const_cast().
subtest 'Inline::CPP::const_cast() tests.' => sub {
    note 'Testing Inline::CPP::const_cast()';
    plan tests => 6;
    my $v = 100;     # Value
    my $c = 0;       # Const boolean test.
    my $t = 'abcde'; # Type.
    is( Inline::CPP::const_cast( $v, $c, $t ), $v,
        "const_cast($v,$c,'$t') returns $v."
    );
    $c = 1;
    is( Inline::CPP::const_cast( $v, $c, $t ), $v,
        "const_cast($v,$c,'$t') returns $v."
    );
    $t = '&abcde';
    $c = 0;
    is( Inline::CPP::const_cast( $v, $c, $t ), $v,
        "const_cast($v,$c,'$t') returns $v."
    );
    $t = '*abcde';
    is( Inline::CPP::const_cast( $v, $c, $t ), $v,
        "const_cast($v,$c,'$t') returns $v."
    );
    $c = 1;
    is( Inline::CPP::const_cast( $v, $c, $t ), "const_cast<$t>($v)",
        "const_cast($v,$c,'$t') returns const_cast<$t>($v)."
    );
    $t = '&abcde';
    is( Inline::CPP::const_cast( $v, $c, $t ), "const_cast<$t>($v)",
        "const_cast($v,$c,'$t') returns const_cast<$t>($v)."
    );
    return;
};


# Test call_or_instantiate().
subtest 'Inline::CPP::call_or_instantiate() tests.' => sub {
    note 'Testing Inline::CPP::call_or_instantiate()';
    plan tests => 3;
    is(
        Inline::CPP::call_or_instantiate(
            qw( name ctor dtor class const *type args1 args2 )
        ),
        "const_cast<*type>(new delete name(args1,args2));\n",
        'call_or_instantiate(): const_cast<*type>(new delete name' .
        '(args1,args2));\n (Test conflation expected)'
    );
    is(
        Inline::CPP::call_or_instantiate(
            'name', undef, undef, 'class', 'const', '&type', 'args1', 'args2'
        ),
        "const_cast<&type>(THIS->name(args1,args2));\n",
        'call_or_instantiate(): const_cast<&type>(THIS->name(args1,args2));\n'
    );
    is(
        Inline::CPP::call_or_instantiate(
            'name', undef, undef, 'class', 'const', '&type', 'args_all'
        ),
        "const_cast<&type>(THIS->name(args_all));\n",
        'call_or_instantiate(): const_cast<&type>(THIS->name(args_all));\n'
    );
    return;
};


done_testing();


