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

test <<'...', 'Comment hides function';
int foo ( int a );
/* int bar ( int a ); */
...

test <<'...', 'Various comments';
// int foo ( int a );
/* int bar ( int a ); */
// comment */ not ended
// comment /* not started
/*
// */ int foo ( int a );
/* comment // comment should end here --> */
...

# test <<'...', 'Simplest class.';
# class Foo {
# };
# ...

# test <<'...', 'Simple class.';
# class Foo {
#   public:
#     Foo() { a = 10; }
#     int fetch() { return a; }
#   private:
#     int a;
# };
# ...
# 
# test <<'...', 'Default-initialized class w/destructor.';
# class Foo {
#   public:
#     Foo() :a(10), b(5) { }
#     int fetcha() { return a; }
#     int fetchb() { return b; }
#     ~Foo() {}
#   private:
#     int a;
#     int b;
# };
# ...

done_testing;
