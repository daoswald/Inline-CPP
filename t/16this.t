use Test::More;

# Try to break object instantiation such that the accessors fetch bad data.


ok(1);

my $obj1 = new_ok( 'ThisTest', [  1,  2,  3 ], '$obj1' );
my $obj2 = new_ok( 'ThisTest', [  4,  5,  6 ], '$obj2' );
my $obj3 = new_ok( 'ThisTest', [  7,  8,  9 ], '$obj3' );
my $obj4 = new_ok( 'ThisTest', [ 10, 11, 12 ], '$obj4' );

#my $obj1 = ThisTest->new(  1,  2,  3 );
isa_ok( $obj1, 'ThisTest', '$obj1' );

#my $obj2 = ThisTest->new(  4,  5,  6 );
isa_ok( $obj2, 'ThisTest', '$obj2' );

#my $obj3 = ThisTest->new(  7,  8,  9 );
isa_ok( $obj3, 'ThisTest', '$obj3' );

#my $obj4 = ThisTest->new( 10, 11, 12 );
isa_ok( $obj4, 'ThisTest', '$obj4' );


is( $obj1->get_this_a,  1, "get_this_a on \$obj1" );
is( $obj1->get_this_b,  2, "get_this_b on \$obj1" );
is( $obj1->get_this_c,  3, "get_this_c on \$obj1" );

is( $obj2->get_this_a,  4, "get_this_a on \$obj2" );
is( $obj2->get_this_b,  5, "get_this_b on \$obj2" );
is( $obj2->get_this_c,  6, "get_this_c on \$obj2" );

is( $obj3->get_this_a,  7, "get_this_a on \$obj3" );
is( $obj3->get_this_b,  8, "get_this_b on \$obj3" );
is( $obj3->get_this_c,  9, "get_this_c on \$obj3" );

is( $obj4->get_this_a, 10, "get_this_a on \$obj4" );
is( $obj4->get_this_b, 11, "get_this_b on \$obj4" );
is( $obj4->get_this_c, 12, "get_this_c on \$obj4" );


##############################################################################

use Inline 'C++' => <<END;

class ThisTest {
 public:
  ThisTest( int a, int b, int c );

  int get_this_a();
  int get_this_b();
  int get_this_c();

 private:
  int a;
  int b;
  int c;
};

ThisTest::ThisTest( int a, int b, int c ) {
   this->a = a;
   this->b = b;
   this->c = c;
}

int ThisTest::get_this_a() {
    return this->a;
}

int ThisTest::get_this_b() {
    return this->b;
}

int ThisTest::get_this_c() {
    return this->c;
}

END

done_testing();
