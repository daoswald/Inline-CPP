package Foo;

use strict;
use warnings;

use Inline CPP => Config => namespace => '';

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

our @ISA = ('Foo');
sub myfetch { my $self = shift; $self->fetch(); }


package main;
use Test::More;

can_ok 'Foo', 'new';
my $f = new_ok 'Foo';
is ref($f), 'Foo', 'Our "Foo" is a "Foo".';
is $f->fetch, '10', 'Accessor properly associated.';


can_ok 'Bar', 'new';
my $bf = new_ok 'Bar';
is ref($bf), 'Bar', 'Our "Bar" is a "Bar"';
is $bf->fetch, 10, 'Proper object method association from Bar.';

done_testing();