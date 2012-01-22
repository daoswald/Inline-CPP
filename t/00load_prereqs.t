
use strict;
use warnings;
use Test::More;

BEGIN {
    diag( "\$ENV{PERL5LIB}: $ENV{PERL5LIB}\n" );
};

BEGIN {
    use_ok( 'Parse::RecDescent' )
        or BAIL_OUT(
            "*** YOU MUST INSTALL Parse::RecDescent BEFORE PROCEEDING ***\n"
        );
    require_ok( 'Inline::C' );
}

done_testing();
