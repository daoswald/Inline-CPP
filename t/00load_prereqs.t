use strict;
use Test::More;
use Config;

BEGIN {
# Some diagnostic information that may be helpful if install fails.
    diag( "\$Config{osname}:     $Config{osname}\n"     );
    diag( "\$Config{cc}:         $Config{cc}\n"         );
    diag( "\$Config{gccversion}: $Config{gccversion}\n" );
};

sub prereq_message {
    return "*** YOU MUST INSTALL $_[0] BEFORE PROCEEDING ***\n";
}

# If Parse::RecDescent isn't cleanly installed there's no point continuing
# the test suite.

BEGIN {
    use_ok( 'Parse::RecDescent' )
        or BAIL_OUT( prereq_message( 'Parse::RecDescent' ) );
    require_ok( 'Inline::C' )
        or BAIL_OUT( prereq_message( 'Inline::C' ) );
}

use_ok( 'Config' );

done_testing();
