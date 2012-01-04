use Test;
BEGIN { plan tests => 2; }
use Inline CPP => <<'END';

class Foo {
   void priv(int a) { q = a; }
   int q;
public:
   Foo() {} 
   ~Foo() {}
   void zippo(int quack) { printf("Hello, world!\n"); }
};

END

ok(1);
Foo->new->zippo(10);
ok(2);
