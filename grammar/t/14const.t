#use strict; # Disabled because tests started randomly failing on some systems.
use Test;
BEGIN { Test::plan( tests => 1 ); }
use Inline CPP => <<'END';
class Foo {
  public:
    Foo()  {}
    ~Foo() {}
    char *data() const { return "Hello dolly!\n"; }
};

END
ok(Foo->new->data, "Hello dolly!\n");
