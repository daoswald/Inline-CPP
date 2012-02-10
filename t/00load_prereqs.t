use strict;
use Test::More;
use Config;

# diag() the PERL5LIB %ENV value so it shows up in smoke test reports.
# This is to help identify the cause of the Parse::RecDescent issue.
BEGIN {
#    diag( "\$ENV{PERL5LIB}:      $ENV{PERL5LIB}\n"      ); # Shouldn't be needed anymore.
# Some diagnostic information for sorting out the Solaris Makefile.PL bug.
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

# --- The following snippet should be unnecessary now that Inline 0.50 and
# --- Inline::CPP 0.34 have fixed the Parse::RecDescent bug.
## If we've made it this far, we found Parse::RecDescent.
## diag() its location so it shows up in smoke test reports.
#if( exists $INC{'Parse/RecDescent.pm'} ) { # This should never fail.
#    diag( "\$INC{'Parse/RecDescent.pm'} => $INC{'Parse/RecDescent.pm'}\n" );
#}

done_testing();
