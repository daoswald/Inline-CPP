#use strict; # Disabled because tests started randomly failing on some systems.

use Test::More;
eval 'use Test::Pod 1.00'; ## no critic (eval)
plan( skip_all => "Test::Pod 1.00 required for testing POD" ) if $@;
all_pod_files_ok();
