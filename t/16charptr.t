# Break object instantiation such that accessors fetch bad data.

use strict;
use warnings;

use Test::More;

use Inline CPP => 'DATA';

# Test verifying classes that store member c-string.

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

done_testing();


__DATA__
__CPP__

class CStrTest {
    public:
        CStrTest( char* a );
        ~CStrTest() { delete[] x; }
        char* get_name();
    private:
        size_t cslen( char *cs );
        char* cscopy( char *cs );
        char* x;
};

CStrTest::CStrTest( char* a ) {
    char* copy = cscopy( a );
    x = copy;
}

char* CStrTest::get_name() {
    return x;
}

size_t CStrTest::cslen( char *cs )
{
    size_t len = 0;
    while( *cs++ )
        len++;
    len += 1;
    return len;
}

char* CStrTest::cscopy ( char *cs )
{
    char *copy = 0;
    char *head = 0;
    size_t len = cslen( cs );
    copy = head = new char[ len ];
    while( *cs )
        *head++ = *cs++;
    *head = 0;
    return copy;
}
