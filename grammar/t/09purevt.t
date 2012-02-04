use Test::More;

use Inline CPP => <<'END';

class Abstract {
  public:
    virtual char *text() = 0;
    virtual int greet(char *name) {
        printf("# Hello, %s.\n", name);
        return 17;
    }
};

class Impl : public Abstract {
  public:
    Impl() {}
    ~Impl() {}
    virtual char *text() { return "Hello from Impl!"; }
};

END

my $o = new_ok( 'Impl' );
is(
    $o->text, 'Hello from Impl!',
    "Pure virtual from self."
);

is(
    $o->greet('Neil'), 17,
    "Inherited from parent."
);

done_testing();
