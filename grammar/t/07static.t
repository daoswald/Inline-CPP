use Test;
BEGIN { plan test => 1 }
use Inline CPP => <<'END';
class Foo {
  public:
    Foo() {}
    ~Foo() {}
    static char *get_string() { return "Hello, world!\n"; }
};
END

ok(Foo->get_string, "Hello, world!\n");
