package main;

use strict;
use warnings;

use Inline CPP => Config => DIRECTORY => '/home/davido/repos/Inline-CPP/_Inline/';
use Inline CPP => Config => BUILD_NOISY => 1, CLEAN_AFTER_BUILD => 0, FORCE_BUILD => 1;
#use Inline CPP => Config => BASE_NAMESPACE => 'main';

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


can_ok 'Foo', 'new';
my $f = Foo->new;
print "Our Foo is a ", ref $f;

done_testing();
