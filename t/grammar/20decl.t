use strict;
use warnings;
use Test::More;

## no critic (eval)

# 

my $rv = eval <<'EOILCPP';
  use Inline CPP => q/
    int add ( int, int );
    int add ( int a, int b ) { return a + b; }
  /;
  1;
EOILCPP

can_ok( 'main', 'add' );



done_testing();
