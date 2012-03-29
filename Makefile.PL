use ExtUtils::MakeMaker;
use Config;

use strict;
use 5.006000;

# We're using bareword file handles and two arg open for backward
# compatibility in Makefile.PL.  Here we disable those tests in Perl::Critic.

## no critic (bareword file handle)
## no critic (two-argument open)


my %PREREQ_PM = (
    'Inline'            => '0.50',
    'Inline::C'         => '0.50',
    'Parse::RecDescent' => '0',
);

#============================================================================
# Makefile.PL will later create this as ilcpptest.cpp to verify that
# the target system uses <iostream> versus <iostream.h> style headers.
#============================================================================

my $test_cpp_filename = 'ilcpptest'; # '.cpp' appended via open.
my $test_cpp = <<'END_TEST_CPP';
#include <iostream>
int main(){
    return 0;
}
END_TEST_CPP


#============================================================================
# We'll do our own prerequisite checking, since MakeMaker does it
# in a way that always fails: 'use Inline::C 0.33' will never work.
#============================================================================
for (sort keys %PREREQ_PM) {
    ## no critic (eval)
    eval "require $_";
    # We eval version numbers to normalize _xxx dev numbering.
    my $have = eval 'no strict q/refs/; ${"${_}::VERSION"}';
    use strict q/refs/;
    my $want = eval $PREREQ_PM{$_};
    warn "Warning: prerequisite $_ version $PREREQ_PM{$_} not found."
        if $@ or $have < $want;
}

#============================================================================
# Make an intelligent guess about what compiler to use
#============================================================================
my $cc_guess;
my $libs_guess;

if ($Config{osname} eq 'darwin'){
    my $stdlib_query =
        'find /usr/lib/gcc -name "libstdc++*" | grep $( uname -p )';
    my $stdcpp =
        `$stdlib_query`; + $stdcpp =~ s/^(.*)\/[^\/]+$/$1/;
    $cc_guess   = 'g++';
    $libs_guess = "-L$stdcpp -lstdc++";
}
elsif (
    $Config{osname} ne 'darwin' and
    $Config{gccversion} and
    $Config{cc} =~ m#\bgcc\b[^/]*$#
) {
    ($cc_guess  = $Config{cc}) =~ s[\bgcc\b([^/]*)$(?:)][g\+\+$1];
    $libs_guess = '-lstdc++ -lgcc_s';  # Added -lgcc_s.
}
elsif ($Config{osname} =~ m/^MSWin/) {
    $cc_guess   = 'cl -TP -EHsc';
    $libs_guess = 'MSVCIRT.LIB';
}
elsif ($Config{osname} eq 'linux') {
    $cc_guess   = 'g++';
    $libs_guess = '-lstdc++';
}
# Dragonfly patch is just a hunch...
elsif( $Config{osname} eq 'netbsd' || $Config{osname} eq 'dragonfly' ) {
    $cc_guess   = 'g++';
    $libs_guess = '-lstdc++ -lgcc_s';
}
elsif ($Config{osname} eq 'cygwin') {
    $cc_guess   = 'g++';
    $libs_guess = '-lstdc++';
}
elsif ($Config{osname} eq 'solaris' or $Config{osname} eq 'SunOS') {
    if (
        $Config{cc} eq 'gcc' ||
        ( exists( $Config{gccversion} ) && $Config{gccversion} > 0 )
    ) {
        $cc_guess   = 'g++';
        $libs_guess = '-lstdc++';
    }
    else {
        $cc_guess   = 'CC';
        $libs_guess ='-lCrun';
    }
}
elsif ($Config{osname} eq 'mirbsd') {
    my $stdlib_query =
        'find /usr/lib/gcc -name "libstdc++*" | grep $( uname -p ) | head -1';
    my $stdcpp =
        `$stdlib_query`; + $stdcpp =~ s/^(.*)\/[^\/]+$/$1/;
    $cc_guess   = 'g++';
    $libs_guess = "-L$stdcpp -lstdc++ -lc -lgcc_s";
}
# Sane defaults for other (probably unix-like) operating systems
else {
    $cc_guess   = 'g++';
    $libs_guess = '-lstdc++';
}

print "This will configure and build Inline::C++.\n";

my $cpp_compiler = prompt(
    "What default C++ compiler would you like to use?",
    $cc_guess
);

my $libs         = prompt(
    "What default libraries would you like to include?",
    $libs_guess
);

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
if( $cpp_compiler =~ m/^cl/ ) {
    # MS compilers don't support -o (or -o is deprecated for them).
    $result = system(
        qq{$cpp_compiler -Fe:$test_cpp_filename.exe } .
        qq{$test_cpp_filename.cpp}
    );
}
else {
    $result = system(
        qq{$cpp_compiler -o $test_cpp_filename.exe } .
        qq{$test_cpp_filename.cpp}
    );
}

my $iostream_fname_style = 'iostream';
my $namespace_std        = "#define __INLINE_CPP_NAMESPACE_STD 1\n";
my $standard_headers     = "#define __INLINE_CPP_STANDARD_HEADERS 1\n";
if( $result != 0 ) {
    # Compiling with <iostream> failed, so we'll assume .h headers.
    print "Detected <iostream.h> style headers. ('.h' needed.)\n";
    $iostream_fname_style = 'iostream.h';
    $namespace_std        = "// $namespace_std";
    $standard_headers     = "// $standard_headers";
}
else {
    # Compiling with <iostream> passed, so we'll assume Standard headers.
    print "Detected <iostream> style headers. ('.h' not needed.)\n";
    unlink "$test_cpp_filename.exe" or warn $!; # Unlink the executable.
}

unlink "$test_cpp_filename.cpp" or warn $!;  # Unlink the test source.


# Apply the defaults:
open CPP, "CPP.pm" or die "Can't read from CPP.pm for configuration!\n$!";
my @lines = <CPP>;
close CPP;

for (@lines) {

    $_ =    "    \$o->{ILSM}{MAKEFILE}{CC}   ||= '$cpp_compiler'; "
            . "# default compiler\n"
        if /# default compiler/;

    $_  =   "    \$o->{ILSM}{MAKEFILE}{LIBS} ||= ['$libs']; "
            . "# default libs\n"
        if /# default libs/;

    $_  =   "    my \$iostream = '$iostream_fname_style';"
            . " # default iostream filename\n"
        if /# default iostream filename/;

    $_  =   $namespace_std
        if /#define __INLINE_CPP_NAMESPACE_STD/;

    $_  =   $standard_headers
        if /#define __INLINE_CPP_STANDARD_HEADERS/;

}

open  CPP, '>CPP.pm'
    or die "Can't write to CPP.pm for configuration!\n$!";

print CPP  @lines
    or die "Can't write to CPP.pm for configuration!\n$!"; # Unlikely.

close CPP
    or die "Can't close CPP.pm after config output!\n$!";


WriteMakefile(
    NAME            => 'Inline::CPP',
    AUTHOR          => 'David Oswald <davido@cpan.org>',
    VERSION_FROM    => 'CPP.pm',
    ABSTRACT_FROM   => 'lib/Inline/CPP.pod',
    PREREQ_PM       => \%PREREQ_PM,
    BUILD_REQUIRES  => {
        'Test::More'    => '0.98', # This is core. Just being explicit.
#        'Test'          => '1.13', # This is core from Perl 5.6.0.
    },
    clean           => {
        FILES           => '_Inline/ grammar/_Inline'
    },
);
