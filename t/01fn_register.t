
use Test::More;

require Inline::CPP;


note "Testing Inline::CPP::register()";
{
    # Data to test register().
    my $language = 'CPP';
    my @language_aliases = qw( cpp C++ Cplusplus CXX c++ cplusplus cxx );
    my $type = 'compiled';

    can_ok( 'Inline::CPP', 'register' );

    like(
        ref( my $href_rv = Inline::CPP::register() ),
        qr/^HASH/,
        'register(): Returns a hashref.'
    );

    is(
        $href_rv->{language}, 'CPP',
        'register(): language attribute set to (CPP)'
    );

    my @aliases = @{ $href_rv->{aliases} };
    is(
        scalar @aliases, scalar @language_aliases,
        'register(): Proper number of aliases returned.'
    );

    is_deeply(
        [ sort @aliases ], [ sort @language_aliases ],
        'register(): Correct set of aliases.'
    );

    is(
        $href_rv->{type}, 'compiled',
        'register(): Correct language type returned (compiled).'
    );

    like(
        $href_rv->{suffix},
        qr/^[\w.]+$/,
        'register(): suffix attribute seems reasonable.'
    );
} # End of register() tests.




done_testing();
