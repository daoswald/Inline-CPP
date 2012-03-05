use strict;
use Test;
BEGIN { plan( tests => 2 ); }

use Inline 'CPP';


my $obj = new Color;
ok(ref $obj, 'main::Color');

$obj->set_color(15);
print $obj->get_color, "\n";

ok($obj->get_color, 15);

__END__
__CPP__
void prn() {
    printf("prn() called!\n");
}

class Color {
 public:
  Color()
  {
    printf("new Color object created...\n");
  }

  ~Color()
  {
    printf("Color object being destroyed...\n");
  }

  int get_color()
  {
    printf("Color::get_color called. Returning %i\n", color);
    return color;
  }

  void set_color(int a)
  {
    printf("Color::set_color(%i)\n", a);
    color = a;
  }

 private:
  int color;
};


