use ExtUtils::CppGuess;
use Config;
use strict;
use Test::More;


my $old_makefile_config = ilcpp_results();
my $eu_cppguess_config  = eucppg_results();

TODO: {
    local $TODO = "Probably will fail: These tests document differences in " .
                  "config detection methods.";
    is(
        $eu_cppguess_config->{compiler},
        $old_makefile_config->{compiler},
        "Compiler and flags for new versus old guess method."
    );
    is(
        $eu_cppguess_config->{libraries},
        $old_makefile_config->{libraries},
        "Libraries for new versus old guess method."
    );
};

diag "\nCompiler guesses:\n" .
     "\tEU::CppGuess:    [$eu_cppguess_config->{compiler}],\n" .
     "\tOld Makefile.PL: [$old_makefile_config->{compiler}].\n";

diag "Linker guesses:\n" .
     "\tEU::CppGuess:    [$eu_cppguess_config->{libraries}],\n" .
     "\tOld Makefile.PL: [$old_makefile_config->{libraries}].";

done_testing();


# Results obtained from Inline::CPP's old Makefile.PL logic.
sub ilcpp_results {
    my $cc_guess;
    my $libs_guess;
    # darwin: Compiler g++, Libs: -Llibstdc++, -lstdc++.
    if ($Config{osname} eq 'darwin'){
        my $stdlib_query =
            'find /usr/lib/gcc -name "libstdc++*" | grep $( uname -p )';
        my $stdcpp =
            `$stdlib_query`; + $stdcpp =~ s/^(.*)\/[^\/]+$/$1/;
        $cc_guess   = 'g++';
        $libs_guess = "-L$stdcpp -lstdc++";
    }
    elsif ( # Basic default - g++ (Strawberry uses this). Libs: -lstdc++.
        $Config{osname} ne 'darwin' and
        $Config{gccversion} and
        $Config{cc} =~ m#\bgcc\b[^/]*$#
    ) {
        ($cc_guess  = $Config{cc}) =~ s[\bgcc\b([^/]*)$(?:)][g\+\+$1];
        $libs_guess = '-lstdc++';
    }
    elsif ($Config{osname} =~ m/^MSWin/) { # Windows: cl -TP -EHsc
        $cc_guess   = 'cl -TP -EHsc';      # MSVCIRT.LIB
        $libs_guess = 'MSVCIRT.LIB';
    }
    elsif ($Config{osname} eq 'linux') {    # Linux: g++ with -lstdc++
        $cc_guess   = 'g++';
        $libs_guess = '-lstdc++';
    }
    elsif( $Config{osname} eq 'netbsd' ) {  # netbsd: g++
        $cc_guess   = 'g++';                # -lstdc++ -lgcc_s
        $libs_guess = '-lstdc++ -lgcc_s';
    }
    elsif ($Config{osname} eq 'cygwin') {   # cygwin: g++
        $cc_guess   = 'g++';                # lstdc++
        $libs_guess = '-lstdc++';
    }
    elsif ($Config{osname} eq 'solaris' or $Config{osname} eq 'SunOS') {
        if (                # Solaris/SunOS with gcc: g++ with libs -lstdc++
            $Config{cc} eq 'gcc' ||
            ( exists( $Config{gccversion} ) && $Config{gccversion} > 0 )
        ) {
            $cc_guess   = 'g++';
            $libs_guess = '-lstdc++';
        }
        else {                  # Solaris/SunOS with CC: CC with libs -lCrun
            $cc_guess   = 'CC'; # Seems wrong.
            $libs_guess ='-lCrun';
        }
    }
    elsif ($Config{osname} eq 'mirbsd') {   # mirbsd: g++
        my $stdlib_query =                  # -Llibstdc++ -lstdc++ -lc -lgcc_s
            'find /usr/lib/gcc -name "libstdc++*" | grep $( uname -p ) | head -1';
        my $stdcpp =
            `$stdlib_query`; + $stdcpp =~ s/^(.*)\/[^\/]+$/$1/;
        $cc_guess   = 'g++';
        $libs_guess = "-L$stdcpp -lstdc++ -lc -lgcc_s";
    }
    # Sane defaults for other (probably unix-like) operating systems
    else {                                  # g++
        $cc_guess   = 'g++';                # -lstdc++
        $libs_guess = '-lstdc++';
    }

    my $cpp_compiler = $cc_guess;
    my $libs         = $libs_guess;
    return { compiler => $cpp_compiler, libraries => $libs };
}


# Results obtained by new ExtUtils::CppGuess dependency.
sub eucppg_results {
    my $cc_guess;
    my $libs_guess;

    my $guesser = ExtUtils::CppGuess->new();
    my %configuration = $guesser->module_build_options();

    if( $guesser->is_gcc() ) {
        $cc_guess = 'g++';
    }
    elsif ( $guesser->is_msvc() )
    {
        $cc_guess = 'cl';
    }

    $cc_guess .= $configuration{extra_compiler_flags};
    $libs_guess = $configuration{extra_linker_flags};

    my $cpp_compiler = $cc_guess;
    my $libs         = $libs_guess;
    return { compiler => $cpp_compiler, libraries => $libs };
}
