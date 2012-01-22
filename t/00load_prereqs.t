use strict;
use Test::More;

BEGIN {
    diag( "\$ENV{PERL5LIB}: $ENV{PERL5LIB}\n" );
};

# If Parse::RecDescent isn't cleanly installed there's no point continuing
# the test suite.

BEGIN {
    use_ok( 'Parse::RecDescent' )
        or BAIL_OUT(
            "*** YOU MUST INSTALL Parse::RecDescent BEFORE PROCEEDING ***\n" .
            "*** After confirming a clean install of Parse::RecDescent, " .
            "you may re-attempt to install Inline::CPP.  If that doesn't " .
            "help, please file a bug report. ***\n"
        );
    require_ok( 'Inline::C' );
}

done_testing();
