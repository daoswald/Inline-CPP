use strict;
use warnings;
use Test::More;


# To enable this suite one must set the RELEASE_TESTING to a true value.
# This prevents author tests from running on a user install.

if ( not $ENV{RELEASE_TESTING} ) {
    plan(
      skip_all =>
        'Author Test: Set $ENV{RELEASE_TESTING} to a true value to run.'
    );
    done_testing();
    exit(0);
}

eval { require Test::Kwalitee; Test::Kwalitee->import() };  ## no cricit (eval)

if( $@ ) {
  plan( skip_all => 'Test::Kwalitee not installed; skipping' );
  done_testing();
  exit(0);
}

# Clean up.  I haven't traced out where this is getting created, but we
# certainly don't need to leave it behind as clutter.

unlink 'Debian_CPANTS.txt' if -e 'Debian_CPANTS.txt';
