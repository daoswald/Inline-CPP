use Test::More;

ok(1);

my $obj1 = Soldier->new( 'Benjamin', 'Private', 11111 );
isa_ok( $obj1, 'Soldier' );

my $obj2 = Soldier->new( 'Sanders', 'Colonel', 22222 );
isa_ok( $obj2, 'Soldier' );

my $obj3 = Soldier->new( 'Matt', 'Sergeant', 33333 );
isa_ok( $obj3, 'Soldier' );

for my $obj ($obj1, $obj2, $obj3) {
   note  $obj->get_serial, ") ",
         $obj->get_name, " is a ",
         $obj->get_rank, "\n";
}

is( $obj1->get_serial, 11111,      "get_serial() on Priave Benjamin." );
is( $obj1->get_name,   'Benjamin', "get_name() on Private Benjamin."  );
is( $obj1->get_rank,   'Private',  "get_rank() on Private Benjamin."  );

is( $obj2->get_serial, 22222,     "get_serial() on Colonel Sanders." );
is( $obj2->get_name,   'Sanders', "get_name() on Colonel Sanders."   );
is( $obj2->get_rank,   'Colonel', "get_rank() on Colonel Sanders."   );

is( $obj3->get_serial, 33333,      "get_serial() on Sergeant Matt."  );
is( $obj3->get_name,   'Matt',     "get_name() on Sergeant Matt."    );
is( $obj3->get_rank,   'Sergeant', "get_rank() on Sergeant Matt."    );

##############################################################################

use Inline 'C++' => <<END;

class Soldier {
 public:
  Soldier(char *name, char *rank, int serial);

  char *get_name();
  char *get_rank();
  int get_serial();

 private:
  char *name;
  char *rank;
  int serial;
};

Soldier::Soldier(char *name, char *rank, int serial) {
   this->name = name;
   this->rank = rank;
   this->serial = serial;
}

char *Soldier::get_name() {
    return name;
}

char *Soldier::get_rank() {
    return rank;
}

int Soldier::get_serial() {
    return serial;
}

END

done_testing();
