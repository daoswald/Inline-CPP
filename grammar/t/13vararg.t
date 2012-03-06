#use strict; # Disabled because tests started randomly failing on some systems.
use Test;
BEGIN { Test::plan( tests => 6 ); }
use Inline 'CPP';

ok(sum(), 0);
ok(sum(1), 1);
ok(sum(1, 2), 3);
ok(sum(1, 2, 3), 6);
ok(sum(1, 2, 3, 4), 10);
ok(sum(1, 2, 3, 4, 5), 15);

__END__
__CPP__

int sum(...) {
    Inline_Stack_Vars;
    int s = 0;
    for (int i=0; i<items; i++)
    {
    int tmp = SvIV(Inline_Stack_Item(i));
    s += tmp;
    }
    return s;
}
