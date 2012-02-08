use Test::More;

use strict;
use warnings;

use Inline CPP => 'DATA';

# Test 1.
is(
    Parent1->new->do_something, 51,
    "Multiple inheritance: Parent1 instantiated, own member function called."
);

# Test 2.
is(
    Parent2->new->do_another, 17,
    "Multiple inheritance: Parent2 instantiated, own member function called."
);

# Test 3.
is(
    Child->new->yet_another, 3,
    "Child inheriting from Parent1, Parent2: instantiate and call own member."
);

# Test 4.
is(
    Child->new->do_something, 51,
    "Child inherited do_something() member function from Parent1"
);

# Test 5.
is(
    Child2->new->some_other, 4,
    "Child2 instantiated and calls own member function some_other()"
);

# Test 6.
is(
    Child2->new->do_another, 17,
    "Child2 inherits do_another() member function from Parent2"
);

TODO: {

    local $TODO = "Inherited method call resolution finding wrong method.";
# Test 7.
    is(
        Child->new->do_another(), 17,
        "Child inherited member function do_another() from Parent2"
    );

# Test 8.
    is(
        Child2->new->do_something(), 51,
        "Child inherited member function do_something() from Parent1"
    );
}

done_testing();

__END__
__CPP__

class Parent1 {
  public:
    Parent1() { }
    ~Parent1() { }

    virtual int do_something() { return 51; }
};

class Parent2 {
  public:
    Parent2();
    ~Parent2();

    virtual int do_another();
};

Parent2::Parent2() { }
Parent2::~Parent2() { }
int Parent2::do_another() { return 17; }

class Child : public Parent1, public Parent2 {
  public:
    Child() { }
    ~Child() { }

    int yet_another() { return 3; }
};

class Child2 : public Parent2, public Parent1 {
  public:
    Child2() { }
    ~Child2() { }

    int some_other() { return 4; }
};
