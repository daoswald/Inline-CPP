use Test::More;

use lib 't';
use TestInlineCPP;

test <<'...';
int add ( int, int );
int foo ( int a );
...

done_testing;
