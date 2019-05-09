use strict;
use warnings;
use Test::More;

# this is needed to avoid false passes if was done first without 'info'
use Inline CPP => config => force_build => 1, clean_after_build => 0;

use Inline CPP => <<'END';

struct Fizzle {
  int q;
  double foozle;
  int quack;
  Fizzle(int Q=0, double Foozle=0, int Quack=0) {
    q = Q;
    foozle = Foozle;
    quack = Quack;
  }
  int get_q() { return q; }
  double get_foozle() { return foozle; }
  int get_quack() { return quack; }
};

END

$SIG{__WARN__} = sub{ die "\nWARNING TRAPPED:",@_ };

my $o = new_ok( 'Fizzle' );

is(
    $o->get_q, 0,
    "Struct with public member function."
);

my $o1 = Fizzle->new(42, 6.75, 123);

done_testing();
