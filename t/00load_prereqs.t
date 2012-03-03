use strict;
use Test::More;
use Config;

#BEGIN {
# Some diagnostic information for sorting out the Solaris Makefile.PL bug.
#    diag( "\$Config{osname}:     $Config{osname}\n"     ); # Unnecessary now.
#    diag( "\$Config{cc}:         $Config{cc}\n"         ); # Unnecessary now.
#    diag( "\$Config{gccversion}: $Config{gccversion}\n" ); # Unnecessary now.
#};

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

done_testing();
