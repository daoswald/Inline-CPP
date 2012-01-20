
use strict;
use warnings;
use Test::More;

BEGIN {
    diag( "\$ENV{PERL5LIB}: $ENV{PERL5LIB}\n" );
};

BEGIN {
    use_ok( 'Parse::RecDescent' );
    require_ok( 'Inline::C' );
}

done_testing();
