# Break object instantiation such that accessors fetch bad data.

use strict;
use warnings;

use Test::More;

use Inline 'C++' => <<END;

class CStrTest {
    public:
        CStrTest( char* a );
        char* get_name();
    private:
        char* x;
};

CStrTest::CStrTest( char* a ) {
   x = a;
}

char* CStrTest::get_name() {
    return x;
}

END


note( 'Subtest: Testing object instantiated by Class->new() syntax.' );

subtest 'Object instantiated with Class->new() syntax.' => sub {
    plan tests => 4;

    my $obj1 = CStrTest->new( 'Honest' );
    my $obj2 = CStrTest->new( 'Lucky'  );
    isa_ok( $obj1, 'CStrTest', '$obj1' );
    isa_ok( $obj2, 'CStrTest', '$obj2' );
    is( $obj1->get_name, 'Honest', "get_name on \$obj1 (Honest)" );
    is( $obj2->get_name, 'Lucky',  "get_name on \$obj2 (Lucky)"  );

};


TODO: {

    local $TODO = 'Tests on new_ok() objects fail. Still investigating why.';

    note(
        'Subtest: Testing object instantiated by ' .
        'Test::More::new_ok() syntax.'
    );

    subtest 'Object instantiated with new_ok().' => sub {
        plan tests => 4;

        my $obj1 = new_ok( 'CStrTest', [ 'Mickey' ], '$obj1' );
        my $obj2 = new_ok( 'CStrTest', [ 'Donald' ], '$obj2' );
        is( $obj1->get_name, 'Mickey', "get_name on \$obj1 (Mickey)" );
        is( $obj2->get_name, 'Donald', "get_name on \$obj2 (Donald)" );
    };

}

done_testing();
