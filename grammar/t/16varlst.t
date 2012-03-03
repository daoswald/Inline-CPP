use strict;
use Test;
# Test declarations of multiple variables in a list
BEGIN { plan tests => 2 }
use Inline CPP => <<'END';

#define NUMBER 25
#define FOO()  25

class Foo {
  public:
    Foo(double _o) : o(_o) {}
    ~Foo() {}
    int test() { return 10; }
  private:
    int a, b;
    char *c, d;
    char *e, *f;
    char g, **h;
    double i, j, *k, **m, n, &o;

    static const int 	aa = 10, 
			bb = FOO(),
			cc = NUMBER,
			dd = 1.25
			;
};

class Bar {
  public:
    Bar() { }
    ~Bar() { }
    int test() { return -1; }
};

END
ok(Foo->new(1.23)->test, 10);
ok(Bar->new->test, -1);
