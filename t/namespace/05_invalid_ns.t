package Foo;
use Test::More;

use strict;
use warnings;

BEGIN {

  my $res
    = eval q{ use Inline CPP => Config => namespace => '!!INVALID!!'; 1; };

  ok( $res != 1, 'Invalid namespace croaks.' );

  like $@, qr/is an invalid package name\./, 'Correct error.';

}

ok(1);

use Inline CPP => <<'EOCPP';

class Foo {
  private:
    int a;
  public:
    Foo() :a(10) {}
    int fetch () { return a; }
};
EOCPP

done_testing();

package main;
