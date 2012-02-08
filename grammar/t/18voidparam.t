
use Test::More;
use Test::Exception;
use Inline CPP => 'DATA';

TODO: {

    local $TODO = 'Not yet implemented: grammar recognizes void param list.';

    my $rv;

    if( 
        lives_ok { $rv = myfunc() } 
                 'grammar recognizes function with void param' 
    ) {
        is( $rv, 100, 'Function with void param yields expected return value.' );
    }
}
done_testing();

__DATA__
__CPP__

int myfunc( void )
{
   return 100;
}
