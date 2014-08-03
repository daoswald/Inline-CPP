use Test::More;

use lib 't';
use TestInlineCPP;

test <<'...', 'Function definition';
int foo ( int a ) { return a; }
...

test <<'...', 'Function declaration (type-only param)';
int add ( int, int );
...

test <<'...', 'Function declaration (named param)';
int foo ( int a );
...

test <<'...', 'Simple class.';
class Foo {
  public:
    Foo() :a(10) { }
    int fetch() { return a }
    ~Foo() {}
  private:
    int a;
};
...

done_testing;
