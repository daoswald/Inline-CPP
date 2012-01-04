use Test;
BEGIN { plan tests => 5 }

use Inline CPP => <<'END';

class Foo {
 public:
   Foo() { 
 	secret=0; 
   }

   ~Foo() { }

   int get_secret() { return secret; }
   void set_secret(int s) { secret = s; }

 protected:
   int secret;
};

class Bar : public Foo {
 public:
   Bar(int s) { secret = s; }
   ~Bar() {  }

   void set_secret(int s) { secret = s * 2; }
};

END

# If it works, it will print this. Otherwise it won't.
ok(1);

# Test Foo
my $o = new Foo;
ok($o->get_secret(), 0);
$o->set_secret(539);
ok($o->get_secret(), 539);

# Test Bar
my $p = new Bar(11);
ok($p->get_secret(), 11);
$p->set_secret(21);
ok($p->get_secret(), 42);

