use ExtUtils::MakeMaker;
use Config;

use strict;

# use 5.006000;

# We're using bareword file handles and two arg open for backward
# compatibility in Makefile.PL.  Here we disable those tests in Perl::Critic.

## no critic (bareword file handle)
## no critic (two-argument open)

my $CPP_Config_path = 'lib/Inline/CPP/Config.pm';

my %PREREQ_PM = (
    'Inline'            => '0.50',
    'Inline::C'         => '0.50',
    'Parse::RecDescent' => '0',
    'Carp'              => '0',
);

#============================================================================
# Makefile.PL will later create this as ilcpptest.cpp to verify that
# the target system uses <iostream> versus <iostream.h> style headers.
#============================================================================

my $test_cpp_filename = 'ilcpptest';        # '.cpp' appended via open.
my $test_cpp          = <<'END_TEST_CPP';
#include <iostream>
int main(){
    return 0;
}
END_TEST_CPP

#============================================================================
# We'll do our own prerequisite checking, since MakeMaker does it
# in a way that always fails: 'use Inline::C 0.33' will never work.
#============================================================================
for ( sort keys %PREREQ_PM ) {
    ## no critic (eval)
    eval "require $_";

    # We eval version numbers to normalize _xxx dev numbering.
    my $have = eval 'no strict q/refs/; ${"${_}::VERSION"}';
    use strict q/refs/;
    my $want = eval $PREREQ_PM{$_};
    warn "Warning: prerequisite $_ version $PREREQ_PM{$_} not found."
        if $@
            or $have < $want;
}

#============================================================================
# Make an intelligent guess about what compiler to use
#============================================================================
my $cc_guess;
my $libs_guess;

if ( $Config{osname} eq 'darwin' ) {
    my $stdlib_query
        = 'find /usr/lib/gcc -name "libstdc++*" | grep $( uname -p )';
    my $stdcpp = `$stdlib_query`;
    +$stdcpp =~ s/^(.*)\/[^\/]+$/$1/;
    $cc_guess   = 'g++';
    $libs_guess = "-L$stdcpp -lstdc++";
}
elsif ( $Config{osname} ne 'darwin'
    and $Config{gccversion}
    and $Config{cc} =~ m#\bgcc\b[^/]*$# )
{
    ( $cc_guess = $Config{cc} ) =~ s[\bgcc\b([^/]*)$(?:)][g\+\+$1];
    $libs_guess = '-lstdc++';
}
elsif ( $Config{osname} =~ m/^MSWin/ ) {
    $cc_guess   = 'cl -TP -EHsc';
    $libs_guess = 'MSVCIRT.LIB';
}
elsif ( $Config{osname} eq 'linux' ) {
    $cc_guess   = 'g++';
    $libs_guess = '-lstdc++';
}

# Dragonfly patch is just a hunch... (still doesn't work)
elsif ( $Config{osname} eq 'netbsd' || $Config{osname} eq 'dragonfly' ) {
    $cc_guess   = 'g++';
    $libs_guess = '-lstdc++ -lgcc_s';
}
elsif ( $Config{osname} eq 'cygwin' ) {
    $cc_guess   = 'g++';
    $libs_guess = '-lstdc++';
}
elsif ( $Config{osname} eq 'solaris' or $Config{osname} eq 'SunOS' ) {
    if ( $Config{cc} eq 'gcc'
        || ( exists( $Config{gccversion} ) && $Config{gccversion} > 0 ) )
    {
        $cc_guess   = 'g++';
        $libs_guess = '-lstdc++';
    }
    else {
        $cc_guess   = 'CC';
        $libs_guess = '-lCrun';
    }
}

# MirBSD: Still problematic.
elsif ( $Config{osname} eq 'mirbsd' ) {
    my $stdlib_query
        = 'find /usr/lib/gcc -name "libstdc++*" | grep $( uname -p ) | head -1';
    my $stdcpp = `$stdlib_query`;
    +$stdcpp =~ s/^(.*)\/[^\/]+$/$1/;
    $cc_guess   = 'g++';
    $libs_guess = "-L$stdcpp -lstdc++ -lc -lgcc_s";
}

# Sane defaults for other (probably unix-like) operating systems
else {
    $cc_guess   = 'g++';
    $libs_guess = '-lstdc++';
}

print "This will configure and build Inline::C++.\n";

my $cpp_compiler
    = prompt( "What default C++ compiler would you like to use?", $cc_guess );

my $libs = prompt( "What default libraries would you like to include?",
    $libs_guess );

#============================================================================
# Test whether the compiler prefers <iostream> or <iostream.h>.
#============================================================================
open TESTCPP, ">$test_cpp_filename.cpp"
    or die "Makefile.PL: Couldn't open $test_cpp_filename for output:\n$!\n";
print TESTCPP $test_cpp;
close TESTCPP
    or die "Makefile.PL: Couldn't close $test_cpp_filename:\n$!\n";

# Compile our test C++ program that includes the <iostream> header.
my $result;
if ( $cpp_compiler =~ m/^cl/ ) {

    # MS compilers don't support -o (or -o is deprecated for them).
    $result = system( qq{$cpp_compiler -Fe:$test_cpp_filename.exe }
            . qq{$test_cpp_filename.cpp} );
}
else {
    $result = system( qq{$cpp_compiler -o $test_cpp_filename.exe }
            . qq{$test_cpp_filename.cpp} );
}

my $iostream_fname = 'iostream';
my $comment        = '';
if ( $result != 0 ) {

    # Compiling with <iostream> failed, so we'll assume .h headers.
    print "Detected <iostream.h> style headers. ('.h' needed.)\n";
    $iostream_fname = 'iostream.h';
    $comment        = '//';           # Prepend a comment to a #define.
}
else {

    # Compiling with <iostream> passed, so we'll assume Standard headers.
    print "Detected <iostream> style headers. ('.h' not needed.)\n";
    unlink "$test_cpp_filename.exe" or warn $!;    # Unlink the executable.
}

unlink "$test_cpp_filename.cpp" or warn $!;        # Unlink the test source.

# Apply the defaults:
open CPP_Config, $CPP_Config_path
    or die "Can't read from $CPP_Config_path for configuration!\n$!";
my @lines = <CPP_Config>;
close CPP_Config;

for (@lines) {
    s{ ( our \s* \$compiler    \s* = \s* ['"] ) [^'"]+ } {$1$cpp_compiler}x;
    s{ ( our \s* \$libs        \s* = \s* ['"] ) [^'"]+ } {$1$libs}x;
    s{ ( our \s* \$iostream_fn \s* = \s* ['"] ) [^'"]+ } {$1$iostream_fname}x;
    s{ ^ [^#]* ( \#define \s+ __INLINE_CPP_NAMESPACE_STD    ) } {$comment$1}x;
    s{ ^ [^#]* ( \#define \s+ __INLINE_CPP_STANDARD_HEADERS ) } {$comment$1}x;
}

open CPP_Config, ">$CPP_Config_path"
    or die "Can't write to $CPP_Config_path for configuration!\n$!";

print CPP_Config @lines
    or die "Can't write to $CPP_Config_path for configuration!\n$!";

close CPP_Config
    or die "Can't close $CPP_Config_path after config output!\n$!";

WriteMakefile(
    NAME           => 'Inline::CPP',
    AUTHOR         => 'David Oswald <davido@cpan.org>',
    VERSION_FROM   => 'CPP.pm',
    ABSTRACT_FROM  => 'lib/Inline/CPP.pod',
    LICENSE        => 'artistic',
    PREREQ_PM      => \%PREREQ_PM,
    BUILD_REQUIRES => {
        'Test::More' => '0.98',    # Core. Minimum version.
        'Config'     => '0',       # Core.
        'English'    => '0',       # Core.
    },
    CONFIGURE_REQUIRES => {
        'ExtUtils::MakeMaker' => '6.56',    # Minimum version.
        'Config'              => '0',       # Core.
    },
    META_MERGE => {
        provides => {
            'Inline::CPP' => {
                file    => 'CPP.pm',
                version => '0.41'
            },
        },
    },
    MIN_PERL_VERSION => '5.006001',
    clean            => { FILES => '_Inline/ grammar/_Inline' },
);
