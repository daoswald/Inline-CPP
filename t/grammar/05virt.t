use strict;
use warnings;
use Test::More;

# this is needed to avoid false passes if was done first without 'info'
use Inline CPP => config => force_build => 1, clean_after_build => 0;


use Inline CPP => <<'END';
class Foo {
  public:
    Foo() { }
    ~Foo() { }

    virtual const char *get_data_ro() { return "Hello Sally!\n"; }
};

class Foo2 {
  public:
    Foo2() { }
    virtual ~Foo2() { }

    virtual const char *get_data_ro() { return "Hello Sue!\n"; }
};

END


is(
    Foo->new->get_data_ro, "Hello Sally!\n",
    "Define and invoke virtual function."
);

is(
    Foo2->new->get_data_ro, "Hello Sue!\n",
    "Use class with virtual dtor."
);

done_testing();
