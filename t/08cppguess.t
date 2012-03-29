use Config;
use strict;
use Test::More tests => 2;
use English qw( -no_match_vars );

my $eucg_found = 1; # True.
eval { require ExtUtils::CppGuess; };
if ( $EVAL_ERROR ) {
    diag( "ExtUtils::CppGuess not installed.  This set of tests and " .
          "diagnostics\n" .
          "is more thorough when ExtUtils::CppGuess can be loaded.\n"
    );
    $eucg_found = 0; # False.
}


my $old_makefile_config = ilcpp_results();
my $eu_cppguess_config  = eucppg_results();

TODO: {
    local $TODO = "Probably will fail: These tests document differences in " .
                  "config detection methods.";
        SKIP: {
            skip
                "ExtUtils::CppGuess required to compare detection methods.", 2
                    unless $eucg_found;
            is(
                $eu_cppguess_config->{compiler},
                $old_makefile_config->{compiler},
                "Compiler / flags for EU::CG versus Makefile.PL guess method."
            );
            is(
                $eu_cppguess_config->{libraries},
                $old_makefile_config->{libraries},
                "Libraries for EU::CG versus Makefile.PL guess method."
            );
        };
};

if( $eucg_found ) {
    diag "\nCompiler guesses:\n" .
         "\tEU::CppGuess:    [$eu_cppguess_config->{compiler}],\n" .
         "\tMakefile.PL: [$old_makefile_config->{compiler}].\n";

    diag "Linker guesses:\n"     .
         "\tEU::CppGuess:    [$eu_cppguess_config->{libraries}],\n" .
         "\tMakefile.PL: [$old_makefile_config->{libraries}].";
}
else {
    diag "\nCompiler guess:\n" .
         "\tMakefile.PL approach: [$old_makefile_config->{compiler}].\n";
    diag "\nLinker guess:\n"   .
         "\tMakefile.PL approach: [$old_makefile_config->{libraries}].\n";
}

done_testing();


# Results obtained from Inline::CPP's old Makefile.PL logic.
sub ilcpp_results {
    my $cc_guess;
    my $libs_guess;
    # darwin: Compiler g++, Libs: -Llibstdc++, -lstdc++.
    if ($Config{osname} eq 'darwin'){
        diag( "Detected darwin\n" );
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
        diag ( "Detected basic defaults (Strawberry, etc.).\n" );
        ($cc_guess  = $Config{cc}) =~ s[\bgcc\b([^/]*)$(?:)][g\+\+$1];
        $libs_guess = '-lstdc++';
    }
    elsif ($Config{osname} =~ m/^MSWin/) { # Windows: cl -TP -EHsc
        diag( "Detected MSWin (probably ActiveState).\n" );
        $cc_guess   = 'cl -TP -EHsc';      # MSVCIRT.LIB
        $libs_guess = 'MSVCIRT.LIB';
    }
    elsif ($Config{osname} eq 'linux') {    # Linux: g++ with -lstdc++
        diag( "Detected Linux." );
        $cc_guess   = 'g++';
        $libs_guess = '-lstdc++ -lgcc_s';  # Added -lgcc_s to 0.38_004.
    }
    elsif( $Config{osname} eq 'netbsd' || $Config{osname} eq 'dragonfly' ) {
        # netbsd: g++.  Added dragonfly to 0.38_004.
        diag( "Detected netbsd or dragonfly." );
        $cc_guess   = 'g++';                # -lstdc++ -lgcc_s
        $libs_guess = '-lstdc++ -lgcc_s';
    }
    elsif ($Config{osname} eq 'cygwin') {   # cygwin: g++
        diag( "Detected cygwin.\n" );
        $cc_guess   = 'g++';                # lstdc++
        $libs_guess = '-lstdc++';
    }
    elsif ($Config{osname} eq 'solaris' or $Config{osname} eq 'SunOS') {
        diag( "Detected solaris or SunOS.\n" );
        if (                # Solaris/SunOS with gcc: g++ with libs -lstdc++
            $Config{cc} eq 'gcc' ||
            ( exists( $Config{gccversion} ) && $Config{gccversion} > 0 )
        ) {
            diag( "Solaris/SunOS with GNU compiler.\n" );
            $cc_guess   = 'g++';
            $libs_guess = '-lstdc++';
        }
        else {                  # Solaris/SunOS with CC: CC with libs -lCrun
            diag( "Solaris/SunOS with CC compiler.\n" );
            $cc_guess   = 'CC'; # Seems wrong.
            $libs_guess ='-lCrun';
        }
    }
    elsif ($Config{osname} eq 'mirbsd') {   # mirbsd: g++
        diag( "Detected mirbsd.\n" );
        my $stdlib_query =                  # -Llibstdc++ -lstdc++ -lc -lgcc_s
            'find /usr/lib/gcc -name "libstdc++*" | grep $( uname -p ) | head -1';
        my $stdcpp =
            `$stdlib_query`; + $stdcpp =~ s/^(.*)\/[^\/]+$/$1/;
        $cc_guess   = 'g++';
        $libs_guess = "-L$stdcpp -lstdc++ -lc -lgcc_s";
    }
    # Sane defaults for other (probably unix-like) operating systems
    else {                                  # g++
        diag( "Fell through to final default: g++ with -lstdc++\n" );
        $cc_guess   = 'g++';                # -lstdc++
        $libs_guess = '-lstdc++';
    }

    my $cpp_compiler = $cc_guess;
    my $libs         = $libs_guess;
    return { compiler => $cpp_compiler, libraries => $libs };
}


# Results obtained by new ExtUtils::CppGuess dependency.
sub eucppg_results {
    my( $cc_guess, $libs_guess    );
    my( $guesser,  %configuration );

    eval {  # ExtUtils::CppGuess may not be available.
        $guesser = ExtUtils::CppGuess->new();
        %configuration = $guesser->module_build_options();

        if( $guesser->is_gcc() ) {
            $cc_guess = 'g++';
        }
        elsif ( $guesser->is_msvc() )
        {
            $cc_guess = 'cl';
        }
    };
    return if $EVAL_ERROR; # Skip if EU::CG isn't loaded.
    $cc_guess .= $configuration{extra_compiler_flags};
    $libs_guess = $configuration{extra_linker_flags};

    my $cpp_compiler = $cc_guess;
    my $libs         = $libs_guess;
    return { compiler => $cpp_compiler, libraries => $libs };
}
