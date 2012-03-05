use strict;

use Test;

BEGIN { plan( tests => 4 ); }

ok(1);

use Inline CPP => DATA => PREFIX => 'Foo_';

ok(identity("Neil"), "Neil");
ok(identity(identity("123")), "123");

ok(Foo->new->dummy, "10");

__END__
__CPP__

struct Foo {
  int dummy() { return 10; }
};

char *Foo_identity(char *in) { return in; }

