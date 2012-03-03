use strict;
use Test;
BEGIN { plan tests => 2 }
use Inline CPP => <<'END';

class Abstract {
  public:
    virtual char *text() = 0;
    virtual int greet(char *name) { 
	printf("Hello, %s\n", name); 
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

my $o = new Impl;
ok($o->text, 'Hello from Impl!');
ok($o->greet('Neil'), 17);
