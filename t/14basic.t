use Test;

BEGIN { plan tests => 10 }

ok(1);

my $obj1 = Soldier->new('Benjamin', 'Private', 11111);
my $obj2 = Soldier->new('Sanders', 'Colonel', 22222);
my $obj3 = Soldier->new('Matt', 'Sergeant', 33333);

for my $obj ($obj1, $obj2, $obj3) {
   print $obj->get_serial, ") ",
         $obj->get_name, " is a ",
         $obj->get_rank, "\n";
}

ok($obj1->get_serial, 11111);
ok($obj1->get_name,   'Benjamin');
ok($obj1->get_rank,   'Private');

ok($obj2->get_serial, 22222);
ok($obj2->get_name,   'Sanders');
ok($obj2->get_rank,   'Colonel');

ok($obj3->get_serial, 33333);
ok($obj3->get_name,   'Matt');
ok($obj3->get_rank,   'Sergeant');

###############################################################################

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
