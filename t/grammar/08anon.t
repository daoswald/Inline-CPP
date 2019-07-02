use strict;
use warnings;
use Test::More;

# this is needed to avoid false passes if was done first without 'info'
use Inline CPP => config => force_build => 1, clean_after_build => 0;

use Inline CPP => <<'END';

class Foo {
  public:
    Foo(int, int);
};

Foo::Foo(int a, int b) {
}

int add(int, int);
int add(int a, int b) { return a + b; }
const char *getstr() { return "Hello Bob!"; }

END

new_ok( 'Foo', [ 10, 11 ] );

is( add( 2, 3 ), 5, "Simple function returning int." );

is( getstr(), "Hello Bob!", "Simple function returning const char *." );

done_testing();
