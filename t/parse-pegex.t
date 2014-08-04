use Test::More;

use lib 't';
use TestInlineCPP;

test <<'...', 'Function definition';
int foo ( int a ) { return a; }
...

test <<'...', 'Function definition with multiple params.';
double foo_bar( char a, double b, int c ) { return b; }
...

# test <<'...', 'Funcition definition with ptr param.';
# int foo( char* a ) { return strlen(a); }
# ...

# test <<'...', 'Function definition returning ptr.';
# char* foo( char* a ) { return a; }
# ...

# test <<'...', 'Function definition accepting a const param.';
# int foo( const int a ) { return a; }
# ...

# test <<'...', 'Function definition returning a const.';
# const int foo ( int a ) { return a; }
# ...

# test <<'...', 'Function definition accepting a ptr to const param.';
# char foo ( char * const a ) { return a[0] }
# ...

# test <<'...', 'Function definition returning a ptr to const.';
# char * const foo ( char * a ) { return static_cast<char * const>(a); }
# ...

# test <<'...', 'Member function definition.';
# int Bar::foo( int a ) { return a; }
# ...

# test <<'...', 'Multi-level namespace function definition.';
# int Bar::Baz::foo( int a ) { return a; }
# ...

# test <<'...', 'Function definition with C++11 return value syntax.';
# auto foo ( int a ) -> int { return a; }
# ...

# test <<'...', 'Function definition accepting a templated container param.';
# int fetch( std::vector<int> a ) { return a.at(0); }
# ...

# test <<'...', 'Function definition returning a templated container param.';
# std::vector<int> fetch( std::vector<int> a ) { return a; }
# ...

# test <<'...', 'Function definition accepting/returning ptr to STL.';
# std::vector<int>* fetch( std::vector<int>* a ) { return a; }
# ...

# test <<'...', 'function definition accepting/returning template of ptrs.';
# std::vector<int*> fetch( std::vector<int*> a ) { return a; }
# ...

# test <<'...', 'Function definition with exception specification.';
# int must_not_throw ( int a ) noexcept { return a; }
# ...

# test <<'...', 'Function definition with affirmitive exception spec.';
# int may_throw ( int a ) throw(int, std::bad_exception) { return a; }
# ...

# test <<'...', 'Function definition with affirmitive empty exception spec.';
# int old_nothrow ( int a ) throw() { return a; }
# ...

test <<'...', 'Function declaration (type-only param)';
int add ( int, int );
...

test <<'...', 'Function declaration (named param)';
int foo ( int a );
...


# test <<'...', 'Function declaration (named ptr param)';
# char foo ( char* abc );
# ...

# test <<'...', 'Function declaration (type-only ptr param)';
# char foo( char* );
# ...

# test <<'...', 'Function declaration retuning ptr.';
# char* foo( char* );
# ...

# test <<'...', 'Function declaration accepting a const param.';
# int foo( const int a );
# ...

# test <<'...', 'Function declaration returning a const.';
# const int foo ( int a );
# ...

# test <<'...', 'Function declaration accepting a ptr to const param.';
# char foo ( char * const a );
# ...

# test <<'...', 'Function declaration returning a ptr to const.';
# char * const foo ( char * a );
# ...

# test <<'...', 'Member function declaration.';
# int Bar::foo( int a );
# ...

# test <<'...', 'Multi-level namespace function declaration.';
# int Bar::Baz::foo( int a );
# ...

# test <<'...', 'Function declaration with C++11 return value syntax.';
# auto foo ( int a ) -> int;
# ...

# test <<'...', 'Function declaration accepting a templated container param.';
# int fetch( std::vector<int> a );
# ...

# test <<'...', 'Function declaration returning a templated container param.';
# std::vector<int> fetch( std::vector<int> a )
# ...

# test <<'...', 'Function declaration accepting/returning ptr to STL.';
# std::vector<int>* fetch( std::vector<int>* a );
# ...

# test <<'...', 'function declaration accepting/returning template of ptrs.';
# std::vector<int*> fetch( std::vector<int*> a );
# ...

# test <<'...', 'Function declaration with exception specification.';
# int must_not_throw ( int a ) noexcept;
# ...

# test <<'...', 'Function declaration with affirmitive exception spec.';
# int may_throw ( int a ) throw(int, std::bad_exception);
# ...

# test <<'...', 'Function declaration with affirmitive empty exception spec.';
# int old_nothrow ( int a ) throw();
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
