use Test::More;

use lib 't';
use TestInlineCPP;

test <<'...', 'Function definition';
int foo ( int a ) { return a; }
...

test <<'...', 'Function declaration';
int add ( int, int );
/* int foo ( int a ); */
...

done_testing;
