package main;

use strict;
use warnings;

use Inline CPP => Config => DIRECTORY => '/home/davido/repos/Inline-CPP/_Inline/';
use Inline CPP => Config => CLEAN_AFTER_BUILD => 0, FORCE_BUILD => 1, namespace => 'Foo';

use Inline CPP => <<'EOCPP';

class Foo {
  private:
    int a;
  public:
    Foo() :a(10) {}
    int fetch () { return a; }
};
EOCPP


package main;
use Test::More;


can_ok 'Foo::Foo', 'new';
my $f = Foo::Foo->new;
diag "Our Foo is a ", ref $f;

done_testing();
