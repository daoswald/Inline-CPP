use strict;
use Test::More;

BEGIN {
    eval "use Test::Exception"; ## no critic (eval)
    plan(
        skip_all =>
        "Test::Exception not installed: Skipping void param tests."
    ) if $@;
}

use Inline CPP => 'DATA';

# This technically fits into Inline's grammar, not Inline::CPP.  The test
# establishes whether or not Inline::C supports explicit 'void' param type.

TODO: {

    local $TODO = 'Not yet implemented: Inline::C grammar ' .
                  'recognizes explicit "void" param list.';

    can_ok( 'main', 'myfunc' );

    my $rv;
    lives_ok { $rv = myfunc() }
             'Try to invoke a function with void in param list.';
    SKIP: {
        skip "Can't test return value on a function that didn't bind.", 1
            if $@;
        is(
            $rv, 100,
            'Function with void param yields expected return value.'
        );
    }

}

done_testing();

__DATA__
__CPP__

int myfunc( void )
{
   return 100;
}
