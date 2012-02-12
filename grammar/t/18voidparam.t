
use Test::More;
use Inline CPP => 'DATA';

# This technically fits into Inline's grammar, not Inline::CPP.  The test 
# establishes whether or not Inline::C supports explicit 'void' param type.

TODO: {

    local $TODO = 'Not yet implemented: Inline::C grammar ' .
                  'recognizes explicit "void" param list.';

    can_ok( 'main', 'myfunc' );

    my $rv;
    eval { $rv = myfunc(); };
    ok( ! $@, 'Call to function with void param type succeeded.' );
    is( $rv, 100, 'Function with void param yields expected return value.' );

}

done_testing();

__DATA__
__CPP__

int myfunc( void )
{
   return 100;
}
