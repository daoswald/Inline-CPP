package Ball;    ## no critic (package)

use strict;
use warnings;

my $foo__bar__myclass = <<'EOCPP';
class MyClass {
  private:
    int a;
  public:
    MyClass() :a(10) {}
    int fetch () { return a; }
};
EOCPP

my $foo__qux__myclass = <<'EOCPP';
#include "/tmp/Foo__Bar__MyClass.c"
class MyClass {
  private:
    int a;
  public:
    MyClass() :a(20) {}
    int fetch () { return a; }
    int other_fetch () { MyClass mybar; return mybar.fetch(); }
};
EOCPP

open( my $FILEHANDLE, '>', '/tmp/Foo__Bar__MyClass.c' )
    or die "Can't open file '/tmp/Foo__Bar__MyClass.c' for writing $!";
print $FILEHANDLE $foo__bar__myclass;
close $FILEHANDLE;

open( $FILEHANDLE, '>', '/tmp/Foo__Qux__MyClass.c' )
    or die "Can't open file '/tmp/Foo__Qux__MyClass.c' for writing $!";
print $FILEHANDLE $foo__qux__myclass;
close $FILEHANDLE;

eval(q[use Inline CPP => '/tmp/Foo__Qux__MyClass.c' => namespace => 'Foo::Qux';]);


package main;
use Test::More skip_all => "Tests purposefully disabled, enable to see C++ class conflict error encountered";

can_ok 'Foo::Bar::MyClass', 'new';
my $fb = new_ok 'Foo::Bar::MyClass';
is ref($fb), 'Foo::Bar::MyClass', 'Our "MyClass" is a "Foo::Bar::MyClass"';

can_ok 'Foo::Qux::MyClass', 'new';
my $fq = new_ok 'Foo::Qux::MyClass';
is ref($fq), 'Foo::Qux::MyClass', 'Our "MyClass" is a "Foo::Qux::MyClass"';

is $fb->fetch,  10, 'Proper object method association from Foo::Bar::MyClass.';
is $fq->fetch, 20, 'Proper object method association from Foo::Qux::MyClass.';
is $fq->other_fetch, 10, 'Proper cross-class method association from Foo::Qux::MyClass.';

done_testing();
