use Test::More;

use strict;
use warnings;


#use Inline CPP               => 'DATA',
#           FORCE_BUILD       => 1,
#           BUILD_NOISY       => 1,
#           CLEAN_AFTER_BUILD => 0;

use Inline CPP => 'DATA';


note( 'Instantiating objects.' );
my @object_descriptions = (
    [
        my $parent1_obj = new_ok( 'Parent1', [], 'Parent1 object born:' ),
        [ qw/ Parent1      / ],
        [ qw/ do_something / ]
    ],
    [
        my $parent2_obj = new_ok( 'Parent2', [], 'Parent2 object born:' ),
        [ qw/ Parent2    /   ],
        [ qw/ do_another /   ]
    ],
    [
        my $child_obj = new_ok( 'Child',     [], 'Child object born:'   ),
        [ qw/ Child          Parent1         Parent2    / ],
        [ qw/ yet_another    do_something    do_another / ]
    ],
    [
        my $child2_obj = new_ok( 'Child2',   [], 'Child2 object born:'  ),
        [ qw/ Child2        Parent1          Parent2    / ],
        [ qw/ some_other    do_something     do_another / ]
    ],
);

note( 'Testing object lineage.' );
foreach my $obj_desc ( @object_descriptions ) {
    foreach my $class ( @{ $obj_desc->[1] } ) {
        ok(
            $obj_desc->[0]->isa( $class ),
            "UNIVERSAL::isa confirms $obj_desc->[1][0] object is a $class."
        );
    }
}

note( 'Testing object method capabilities (inheritance).' );
foreach my $obj_desc ( @object_descriptions ) {
    foreach my $func_name ( @{ $obj_desc->[2] } ) {
        can_ok( $obj_desc->[0], $func_name );
    }
}


note( 'Testing \@Class::ISA arrays.' );
is_deeply( \@Parent1::ISA, [ ], "\@Parent1::ISA: No inheritance." );
is_deeply( \@Parent2::ISA, [ ], "\@Parent2::ISA: No inheritance." );
TODO: {
    local $TODO = "Still researching why Child and Child2 inherit via main::";
    is_deeply(
        \@Child::ISA,   [ qw/ Parent1   Parent2 / ],
        "\@Child::ISA: Parent1, Parent2."
    );
    is_deeply(
        \@Child2::ISA,  [ qw/ Parent2   Parent1 / ],
        "\@Child2::ISA: Parent2, Parent1."
    );
}

my @method_tests = (
    [
        $parent1_obj,
        'Parent1',
        {
            do_something => 51
        }
    ],
    [
        $parent2_obj,
        'Parent2',
        {
            do_another   => 17
        }
    ],
    [
        $child_obj,
        'Child',
        {
            yet_another  => 3,
            do_something => 51,
            do_another   => 17,
        },
    ],
    [
        $child2_obj,
        'Child2',
        {
            some_other   => 4,
            do_something => 51,
            do_another   => 17
        }
    ],
);

note( 'Testing that object methods return correct values' );
TODO: {
    foreach my $obj_task ( @method_tests ) {
        while( my( $method, $expect ) = each %{ $obj_task->[2] } ) {
            local $TODO =
                'Still working on why multiple inheritance is messed up.'
                if( $obj_task->[1] =~ /Child\d?/ );
            is(
                $obj_task->[0]->$method, $expect,
                "$obj_task->[1] object method $method " .
                "correctly returns $expect."
            );
        }
    }
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
