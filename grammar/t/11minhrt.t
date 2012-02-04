use Test::More;


use Inline CPP;

is(
    Parent1->new->do_something, 51,
    "Multiple inheritance: First parent instantiated."
);

is(
    Parent2->new->do_another, 17,
    "Multiple inheritance: Second parent instantiated."
);

is(
    Child->new->yet_another, 3,
    "Child inheriting from Parent1, Parent2: instantiate and call own member."
);

is(
    Child->new->do_something, 51,
    "Child inherited member function from Parent1"
);

TODO: {

    local $TODO = "Inherited method call resolution finding wrong method.";
    is(
        Child->new->do_another(), 17,
        "Child inherited member function from Parent2"
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
