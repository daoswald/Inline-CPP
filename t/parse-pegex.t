use Test::More;

use lib 't';
use TestInlineCPP;

test <<'...', 'Function definition';
int foo ( int a ) { return a; }
...

test <<'...', 'Function declaration (type-only param)';
int add ( int, int );
...

test <<'...', 'Function declaration (named param)'
int foo ( int a );
...

done_testing;
