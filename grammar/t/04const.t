use strict;
use Test;
BEGIN { plan( tests => 1 ); }
use Inline CPP => <<'END';
class Foo {
  public:
    Foo()  {}
    ~Foo() {}
    const char *data() { return "Hello dolly!\n"; }
};

END
ok(Foo->new->data, "Hello dolly!\n");
