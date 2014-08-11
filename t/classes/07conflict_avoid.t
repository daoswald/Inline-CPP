package Ball;    ## no critic (package)

use strict;
use warnings;
use File::Temp 'tempdir';


my $foo__bar__myclass = <<'EOCPP';

  class Foo__Bar__MyClass {
    private:
      int a;
    public:
      Foo__Bar__MyClass() :a(10) {}
      int fetch () { return a; }
  };

EOCPP


my $foo__qux__myclass = <<'EOCPP';

#include "/tmp/Foo__Bar__MyClass.c"

  class Foo__Qux__MyClass {
    private:
      int a;
    public:
      Foo__Qux__MyClass() :a(20) {}
      int fetch () { return a; }
      int other_fetch () { Foo__Bar__MyClass mybar; return mybar.fetch(); }
  };

EOCPP


my $tdir = tempdir( CLEANUP => 1 );

open my $fha, '>', "$tdir/Foo__Bar__MyClass.c"
  or die "Can't open file '/tmp/Foo__Bar__MyClass.c' for writing $!";
print $fha $foo__bar__myclass;
close $fha;

open my $fhb, '>', "$tdir/Foo__Qux__MyClass.c"
  or die "Can't open file '/tmp/Foo__Qux__MyClass.c' for writing $!";
print $fhb $foo__qux__myclass;
close $fhb;

eval q[
  use Inline CPP =>
    "$tdir/Foo__Qux__MyClass.c", 
    filters   => 'Preprocess', 
    namespace => 'Foo', 
    classes   => {
      'Foo__Bar__MyClass' => 'Bar::MyClass',
      'Foo__Qux__MyClass' => 'Qux::MyClass'
    };
];

unlink "$tdir/Foo__Bar__MyClass.c", "$tdir/Foo__Qux__MyClass.c";

package main;

use Test::More;

plan skip_all => "Inline::Filters required for conflict avoidance testing."
  unless eval q{ require Inline::Filters; 1; };



can_ok 'Foo::Bar::MyClass', 'new';

my $fb = new_ok 'Foo::Bar::MyClass';

is ref($fb), 'Foo::Bar::MyClass', 'Our "MyClass" is a "Foo::Bar::MyClass"';

can_ok 'Foo::Qux::MyClass', 'new';

my $fq = new_ok 'Foo::Qux::MyClass';

is ref($fq), 'Foo::Qux::MyClass', 'Our "MyClass" is a "Foo::Qux::MyClass"';

is $fb->fetch,  10, 'Proper object method association from Foo::Bar::MyClass.';

is $fq->fetch, 20, 'Proper object method association from Foo::Qux::MyClass.';

is $fq->other_fetch, 10,
  'Proper cross-class method association from Foo::Qux::MyClass.';

done_testing();
