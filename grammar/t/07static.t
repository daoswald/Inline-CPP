#use strict; # Disabled because tests started randomly failing on some systems.
use Test;
BEGIN { Test::plan( test => 1 ); }
use Inline CPP => <<'END';
class Foo {
  public:
    Foo() {}
    ~Foo() {}
    static char *get_string() { return "Hello, world!\n"; }
};
END

ok(Foo->get_string, "Hello, world!\n");
