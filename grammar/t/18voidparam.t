
use Test::More;

BEGIN {
    eval "use Test::Exception";
    plan( 
        skip_all => 
        "Test::Exception not installed: Skipping void param tests." 
    ) if $@;
}

use Inline CPP => 'DATA';

# This technically fits into Inline's grammar, not Inline::CPP.  The test 
# establishes whether or not Inline::C supports explicit 'void' param type.

diag( "Tests in 18voidparam.t may generate warnings from CPP.pm." );

TODO: {

    local $TODO = 'Not yet implemented: Inline::C grammar ' .
                  'recognizes explicit "void" param list.';

    can_ok( 'main', 'myfunc' );

    my $rv;
    lives_ok { $rv = myfunc() } 
             'Try to invoke a function with void in param list.';
#    my $test_result = $@;
#    ok( ! $@, 'Call to function with void param type succeeded.' );
#    if( $test_result ) {
#        chomp $test_result;
#        diag ( "Test failure reason: [$eval_result]" );
#    }
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
