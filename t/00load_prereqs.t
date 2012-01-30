use strict;
use Test::More;

# diag() the PERL5LIB %ENV value so it shows up in smoke test reports.
# This is to help identify the cause of the Parse::RecDescent issue.
BEGIN {
    diag( "\$ENV{PERL5LIB}: $ENV{PERL5LIB}\n" );
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

# If we've made it this far, we found Parse::RecDescent.
# diag() its location so it shows up in smoke test reports.
if( exists $INC{'Parse/RecDescent.pm'} ) { # This should never fail.
    diag( "\$INC{'Parse/RecDescent.pm'} => $INC{'Parse/RecDescent.pm'}\n" );
}

done_testing();
