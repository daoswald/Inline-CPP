
use Test::More;

# Originally one of these tests was passing char* strings, there's no need
# to test strings, and doing so adds unnecessary complexity to the test.

ok(1);

use Inline CPP => DATA => PREFIX => 'Foo_';

is(identity( 100 ), 100, "PREFIX resolved." );
is(identity(identity( 200 )), 200, "PREFIX resolved in nested calls." );

is(Foo->new->dummy, "10", "PREFIXed object resolves." );

done_testing();

__END__
__CPP__

struct Foo {
  int dummy() { return 10; }
};

int Foo_identity( int in ) { return in; }

