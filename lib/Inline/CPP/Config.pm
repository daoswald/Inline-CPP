package Inline::CPP::Config;

# Configuration data for CPP.pm; Compiler, libs, iostream filename, #defines.

use strict;
use warnings;

our $VERSION = '0.38_004';
$VERSION = eval $VERSION;



# DO NOT MANUALLY ALTER THE FOLLOWING TWO LINES: Makefile.PL locates them by
# matching their syntax and identifier names.
our $compiler = 'g++';
our $libs     = '-lstdc++';



# DO NOT MANUALLY ALTER THE FOLLOWING LINE: Makefile.PL locates it by
# matching its syntax and identifier name.
our $iostream_fn = 'iostream';



# DON'T EDIT THIS HERE-DOC.  These are set by Makefile.PL.  Override
# by supplying undefs in an AUTO_INCLUDE configuration.
our $cpp_flavor_defs =  <<'END_FLAVOR_DEFINITIONS';

#define __INLINE_CPP_STANDARD_HEADERS 1
#define __INLINE_CPP_NAMESPACE_STD 1

END_FLAVOR_DEFINITIONS


1;
