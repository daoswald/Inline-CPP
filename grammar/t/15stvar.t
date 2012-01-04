use Test;
# Test static variables
BEGIN { plan tests => 1 }
use Inline CPP => <<'END';
class Foo {
  public:
    Foo()  {}
    ~Foo() {}
    static int get_thing() { return s_thing; }
  private:
    static int s_thing;
};

int Foo::s_thing = 10;

END
ok(Foo->new->get_thing, 10);
