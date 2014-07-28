package Foo;

use strict;
use warnings;

use Inline CPP => Config => namespace         => '';

use Inline CPP => <<'EOCPP';

class Foo {
  private:
    int a;
  public:
    Foo() :a(10) {}
    int fetch () { return a; }
};
EOCPP

1;

package Bar;

our @ISA = 'Foo';
sub myfetch { my $self = shift; $self->fetch() }

1;

package main;
use Test::More;

can_ok 'Bar::Foo', 'new';
my $f = new_ok 'Bar::Foo';
is ref($f), 'Bar::Foo', 'Our "Foo" is a "Bar::Foo"';


is $f->fetch, 10, 'Proper object method association from Baz::Foo.';

done_testing();
