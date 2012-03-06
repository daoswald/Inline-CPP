#use strict; # Disabled because tests started randomly failing on some systems.
use Test;
BEGIN { Test::plan( tests => 1 ); }
use Inline CPP => <<'END';
class Foo {
  public:
    Foo() { }
    ~Foo() { }

    virtual const char *get_data_ro() { return "Hello Sally!\n"; }
};
END
ok(Foo->new->get_data_ro, "Hello Sally!\n");
