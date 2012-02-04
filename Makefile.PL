use ExtUtils::MakeMaker;
use Config;

my %PREREQ_PM = (
    'Inline'            => '0.49_02',
    'Inline::C'         => '0.49_02',
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
    eval "require $_";
    my $have = eval ${"${$_}::VERSION"};
    my $want = eval $PREREQ_PM{$_};
    warn "Warning: prerequisite $_ version $PREREQ_PM{$_} not found"
        if $@ or $have < $want;
}

#============================================================================
# Make an intelligent guess about what compiler to use
#============================================================================
my $cc_guess;
my $libs_guess;
if ($Config{gccversion} and $Config{cc} =~ m#\bgcc\b[^/]*$# ) {
    ($cc_guess = $Config{cc}) =~ s[\bgcc\b([^/]*)$(?:)][g\+\+$1];
    $libs_guess = '-lstdc++';
}
elsif ($Config{osname} =~ /^MSWin/) {
    $cc_guess = 'cl -TP -EHsc';
    $libs_guess = 'MSVCIRT.LIB';
}
elsif ($Config{osname} eq 'linux') {
    $cc_guess = 'g++';
    $libs_guess = '-lstdc++';
}
elsif ($Config{osname} eq 'cygwin') {
    $cc_guess = 'g++';
    $libs_guess = '-lstdc++';
}
elsif ($Config{osname} eq 'darwin'){
    my $stdlib_query =
        'find /usr/lib/gcc -name "libstdc++*" | grep $( uname -p )';
    my $stdcpp =
        `$stdlib_query`; + $stdcpp =~ s/^(.*)\/[^\/]+$/$1/;
    $cc_guess =
        'g++';
    $libs_guess =
        "-L$stdcpp -lstdc++";
}
elsif ($Config{osname} eq 'solaris' or $Config{osname} eq 'SunOS') {
    if ($Config{cc} eq 'gcc') {
        $cc_guess = 'g++';
        $libs_guess = '-lstdc++';
    }
    else {
        $cc_guess = 'CC';
        $libs_guess ='-lCrun';
    }
}
# Sane defaults for other (probably unix-like) operating systems
else {
    $cc_guess = 'g++';
    $libs_guess = '-lstdc++';
}

print "This will configure and build Inline::C++.\n";

my $cpp_compiler = prompt(
        "What default C++ compiler would you like to use?",
        $cc_guess
);

my $libs = prompt(
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
if( $cpp_compiler =~ /^cl/ ) {
    # MS compilers don't support -o (or -o is deprecated for them).
    $result = system(
        qq{$cpp_compiler -Fe:$test_cpp_filename.exe } .
        qq{$test_cpp_filename.cpp}
    );
} else {
    $result = system(
        qq{$cpp_compiler -o $test_cpp_filename.exe } .
        qq{$test_cpp_filename.cpp}
    );
}

my $iostream_fname_style = 'iostream';
my $namespace_std    = "#define __INLINE_CPP_NAMESPACE_STD 1\n";
my $standard_headers = "#define __INLINE_CPP_STANDARD_HEADERS 1\n";
if( $result != 0 ) {
    # Compiling with <iostream> failed, so we'll assume .h headers.
    print "Detected <iostream.h> style headers. ('.h' needed.)\n";
    $iostream_fname_style = 'iostream.h';
    $namespace_std    = "// $namespace_std";
    $standard_headers = "// $standard_headers";
} else {
    # Compiling with <iostream> passed, so we'll assume Standard headers.
    print "Detected <iostream> style headers. ('.h' not needed.)\n";
    unlink "$test_cpp_filename.exe" or warn $!; # Unlink the executable.
}

unlink "$test_cpp_filename.cpp" or warn $!;  # Unlink the test source.


# Apply the defaults:
open CPP, "CPP.pm";
my @lines = <CPP>;
close CPP;

for (@lines) {

    $_ =    " \$o->{ILSM}{MAKEFILE}{CC} ||= '$cpp_compiler'; "
            . "# default compiler\n"
        if /# default compiler/;

    $_  =   " \$o->{ILSM}{MAKEFILE}{LIBS} ||= ['$libs']; "
            . "# default libs\n"
        if /# default libs/;

    $_  =   " my \$iostream = '$iostream_fname_style';"
            . " # default iostream filename\n"
        if /# default iostream filename/;

    $_  =   $namespace_std
        if /#define __INLINE_CPP_NAMESPACE_STD/;

    $_  =   $standard_headers
        if /#define __INLINE_CPP_STANDARD_HEADERS/;

}

open CPP, ">CPP.pm" or die "Can't write to CPP.pm!";
print CPP @lines;
close CPP or die "Can't close CPP.pm after output!";


WriteMakefile(
    NAME            => 'Inline::CPP',
    AUTHOR          => 'David Oswald <davido@cpan.org>',
    VERSION_FROM    => 'CPP.pm',
    ABSTRACT_FROM	=> 'lib/Inline/CPP.pod',
    PREREQ_PM       => \%PREREQ_PM,
    clean           => {
        FILES           => '_Inline/ grammar/_Inline'
    },
);
