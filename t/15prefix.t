
use Test::More;


ok(1);

use Inline CPP => DATA => PREFIX => 'Foo_';

is(identity("Neil"), "Neil", "PREFIX resolved." );
is(identity(identity("123")), "123", "PREFIX resolved in nested calls." );

is(Foo->new->dummy, "10", "PREFIXed object resolves." );

done_testing();

__END__
__CPP__

struct Foo {
  int dummy() { return 10; }
};

char *Foo_identity(char *in) { return in; }

