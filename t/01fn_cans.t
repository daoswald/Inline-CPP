
use Test::More;

require Inline::CPP;

can_ok( 'Inline::CPP', qw/
    call_or_instantiate     check_type      const_cast
    get_parser              info            make_enum
    register                typeconv        validate
    wrap                    write_typemap   xs_bindings
    xs_generate
/ );

done_testing();
