use Test::More;

use lib 't';
use TestInlineCPP;

test <<'...', 'Function definition';
int foo ( int a ) { return a; }
...

test <<'...', 'Function definition with multiple params.';
double foo_bar( char a, double b, int c ) { return b; }
...

# test <<'...', 'Function definition with exception specification.';
# int must_not_throw ( int a ) noexcept { return a; }
# ...

# test <<'...', 'Funcition definition with ptr param.';
# int foo( char* a ) { return strlen(a); }
# ...

# test <<'...', 'Function definition returning ptr.';
# char* foo( char* a ) { return a; }
# ...

# test <<'...', 'Member function definition.';
# int Bar::foo( int a ) { return a; }
# ...

# test <<'...', 'Multi-level namespace function definition.';
# int Bar::Baz::foo( int a ) { return a; }
# ...

test <<'...', 'Function declaration (type-only param)';
int add ( int, int );
...

test <<'...', 'Function declaration (named param)';
int foo ( int a );
...

# test <<'...', 'Function declaration with exception specification.';
# int must_not_throw ( int a ) noexcept;
# ...

# test <<'...', 'Function declaration (named ptr param)';
# char foo ( char* abc );
# ...

# test <<'...', 'Function declaration (type-only ptr param)';
# char foo( char* );
# ...

# test <<'...', 'Function declaration retuning ptr.';
# char* foo( char* );
# ...

# test <<'...', 'Member function declaration.';
# int Bar::foo( int a );
# ...

# test <<'...', 'Multi-level namespace function declaration.';
# int Bar::Baz::foo( int a );
# ...



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
