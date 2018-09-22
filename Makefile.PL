use ExtUtils::MakeMaker;
use FindBin;
use lib "$FindBin::Bin/inc";
use ILCPPConfig::CompilerGuess 'guess_compiler';
use Fcntl qw(:DEFAULT);
use strict;
use 5.010000;


# We're using bareword file handles and two arg open for backward
# compatibility in Makefile.PL.  Here we disable those tests in Perl::Critic.
## no critic (bareword file handle)
## no critic (two-argument open)

# The next line is verified via t/13version_numbers.t. Retain single quoting.

my $DIST_VERSION    = '0.75';                        # DRY in Makefile.PL.

my $CPP_Config_path = 'lib/Inline/CPP/Config.pm';

my $test_cpp_filename = 'ilcpptest';        # '.cpp' appended via open.
my $test_cpp          = <<'END_TEST_CPP';
#include <iostream>
int main(){ return 0; }
END_TEST_CPP

my %PREREQ_PM = (
  'Inline'            => '0.78',
  'Inline::C'         => '0.79', # supports 5.8.1
  'Parse::RecDescent' => '0',
  'Carp'              => '0',
);


check_prereqs(\%PREREQ_PM) or warn "!!! PREREQUISITES NOT MET !!!";

my($cc_guess, $libs_guess) = guess_compiler();

my $cpp_compiler
  = prompt("What C++ compiler would you like to use?", $cc_guess);

my $libs
  = prompt("What default libraries would you like to include?", $libs_guess);

configure_distribution($test_cpp_filename, $cpp_compiler, $libs);

WriteMakefile(
  NAME           => 'Inline::CPP',
  AUTHOR         => 'David Oswald <davido@cpan.org>',
  VERSION_FROM   => 'lib/Inline/CPP.pm',
  ABSTRACT_FROM  => 'lib/Inline/CPP.pod',
  LICENSE        => 'artistic_2',
  PREREQ_PM      => \%PREREQ_PM,
  BUILD_REQUIRES => {
    'Test::More' => '1.001009',    # Core. Minimum version.
    'Config'     => '0',           # Core.
    'English'    => '0',           # Core.
    'File::Temp' => '0',           # Core.
  },
  CONFIGURE_REQUIRES => {
    'ExtUtils::CppGuess'  => '0.11',    # Beginning IL::CPP 0.54_001.
    'ExtUtils::MakeMaker' => '7.04',    # Core.
    'FindBin'             => '0',       # Core.
    'Config'              => '0',       # Core.
  },
  META_MERGE => {
    'meta-spec' => {
      version => 2,
      url     => 'http://search.cpan.org/perldoc?CPAN::Meta::Spec',
    },
    no_index   => { directory => [ 'inc' ], },
    resources   => {
      license    => 'http://dev.perl.org/licenses/artistic.html',
      bugtracker => 'http://github.com/daoswald/Inline-CPP/issues',
      homepage   => 'http://github.com/daoswald/Inline-CPP',
      repository => {
        type => 'git',
        url  => 'http://github.com/daoswald/Inline-CPP.git',
        web  => 'http://github.com/daoswald/Inline-CPP',
      },
    },
    provides   => {
      'Inline::CPP' => {
        file    => 'lib/Inline/CPP.pm',
        version => $DIST_VERSION,
      },
      'Inline::CPP::Parser::RecDescent' => {
        file    => 'lib/Inline/CPP/Parser/RecDescent.pm',
        version => $DIST_VERSION,
      },
      'Inline::CPP::Config' => {
        file    => 'lib/Inline/CPP/Config.pm',
        version => $DIST_VERSION,
      },
    },
    prereqs => {
      develop => {
        requires => {
          'Test::Pod' => '1.00',
          'Test::Perl::Critic' => 0,
          'Test::Pod::Coverage' => '1.00',
          'Test::Kwalitee' => 0,
          'Test::CPAN::Changes' => 0,
          'Test::CheckManifest' => '0.9',
        },
      },
    },
  },
  MIN_PERL_VERSION => '5.008001',
  test  => {RECURSIVE_TEST_FILES => 1},
  clean => {FILES => join q{ }, $CPP_Config_path, qw{
    _Inline/            t/_Inline
    t/classes/_Inline   t/grammar/_Inline
    t/namespace/_Inline Inline-CPP-*/
  }}, # Paths can be space delimited.
);

#============================================================================
# We'll do our own prerequisite checking, since MakeMaker does it
# in a way that always fails: 'use Inline::C 0.33' will never work.
#============================================================================

sub check_prereqs {
  my $prereq_pm_href = shift;
  my $prereqs_ok = 1;

  for(sort keys %$prereq_pm_href) {
    ## no critic (eval);
    eval "require $_";

    # We eval version numbers to normalize _xxx dev numbering.
    my $have = eval 'no strict q/refs/; ${"${_}::VERSION"}';

    use strict q/refs/;

    my $want = eval $prereq_pm_href->{$_};

    if($@ || $have < $want) {
      warn "Warning: prerequisite $_ version $prereq_pm_href->{$_} not found.";
      $prereqs_ok = 0;
    }
  }
  return $prereqs_ok;
}


###############################################################################
# Test for appropriate header style.
# Configure distribution defaults in Inline::CPP::Config.pm.
###############################################################################

sub to_file {
  my ($file, @data) = @_;
  local *FH;
  sysopen FH, $file, O_WRONLY | O_CREAT
    or die "Makefile.PL: Couldn't open $file for output: $!\n";
  truncate FH, 0 or die "Makefile.PL: Couldn't truncate $file: $!\n";
  print FH @data;
  close FH or die "Makefile.PL: Couldn't close $file: $!\n";
}

sub from_file {
  my ($file) = @_;
  local *FH;
  open FH, '<', $file
    or die "Makefile.PL: Can't read from $file: $!";
  <FH>;
}

sub configure_distribution {
  my( $test_cpp_filename, $cpp_compiler, $libs ) = @_;

  # Test whether the compiler prefers <iostream> or <iostream.h>.
  to_file "$test_cpp_filename.cpp", $test_cpp;
  # Compile our test C++ program that includes the <iostream> header.
  my $result;
  if ($cpp_compiler =~ m/^cl/) {
    # MS compilers don't support -o (or -o is deprecated for them).
    $result = system(
        qq{$cpp_compiler -Fe:$test_cpp_filename.exe $test_cpp_filename.cpp}
    );
  }
  else {
    $result = system(
        qq{$cpp_compiler -o $test_cpp_filename.exe $test_cpp_filename.cpp}
    );
  }
  my $iostream_fname = 'iostream';
  my $comment        = '';
  if ($result != 0) {
    # Compiling with <iostream> failed, so we'll assume .h headers.
    print "Detected <iostream.h> style headers. ('.h' needed.)\n";
    $iostream_fname = 'iostream.h';
    $comment        = '//';                 # Prepend a comment to a #define.
  }
  else {
    # Compiling with <iostream> passed, so we'll assume Standard headers.
    print "Detected <iostream> style headers. ('.h' not needed.)\n";
    unlink "$test_cpp_filename.exe" or warn $!;     # Unlink the executable.
  }
  unlink "$test_cpp_filename.cpp" or warn $!;         # Unlink the test source.

  # Apply the distribution defaults:
  my @lines = from_file("$CPP_Config_path.in");
  for (@lines) {
    s{(our \s* \$compiler    \s* = \s* ['"]) [^'"]+}{$1$cpp_compiler}x;
    s{(our \s* \$libs        \s* = \s* ['"]) [^'"]+}{$1$libs}x;
    s{(our \s* \$iostream_fn \s* = \s* ['"]) [^'"]+}{$1$iostream_fname}x;
    s{^ [^#]* (\#define \s+ __INLINE_CPP_NAMESPACE_STD   )}{$comment$1}x;
    s{^ [^#]* (\#define \s+ __INLINE_CPP_STANDARD_HEADERS)}{$comment$1}x;
  }
  to_file $CPP_Config_path, @lines;
}
