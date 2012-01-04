use Test;
BEGIN { plan tests => 1 }
use Inline CPP => <<'END';

class Foo {
  public:
    Foo(int, int);
};

Foo::Foo(int a, int b) {

}

int add(int, int);
int add(int a, int b) { return a + b; }

END

ok(defined Foo->new(10, 11));
