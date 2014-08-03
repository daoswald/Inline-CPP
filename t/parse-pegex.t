use Test::More;

use lib 't';
use TestInlineCPP;

test <<'...';
int foo ( int a ) { return a }
...

done_testing;
