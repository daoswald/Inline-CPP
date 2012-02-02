package Inline::CPP;

#============================================================================
# Editing Best practices:
#     Unix line endings.
#     Four spaces for indentation (no tabs).
#     Conditional modifiers go on the following line, indented four spaces.
#     Others as issues reveal themselves.
#============================================================================

use strict;

require Inline::C;
require Inline::CPP::grammar;
use Carp;

use vars qw(@ISA $VERSION);

@ISA = qw(Inline::C);

# Development releases will have a _0xx version suffix.
$VERSION = '0.33_008';
$VERSION = eval $VERSION; # To accommodate dev. version numbers.



my $TYPEMAP_KIND = $Inline::CPP::grammar::TYPEMAP_KIND;

#============================================================================
# Register Inline::CPP as an Inline language module
#============================================================================
sub register {
    use Config;
    return {
        language => 'CPP',
        aliases => ['cpp', 'C++', 'c++', 'Cplusplus', 'cplusplus', 'CXX', 'cxx'],
        type => 'compiled',
        suffix => $Config{dlext},
       };
}

#============================================================================
# Validate the C++ config options: Now mostly done in Inline::C
#============================================================================
sub validate {
    my $o = shift;
    # Do not alter the following two lines: Makefile.PL locates them by
    # their comment text and alters them based on install inputs.
 $o->{ILSM}{MAKEFILE}{CC} ||= 'g++'; # default compiler
 $o->{ILSM}{MAKEFILE}{LIBS} ||= ['-lstdc++']; # default libs

    # I haven't traced it out yet, but $o->{STRUCT} gets set before getting
    # properly set from Inline::C's validate().
    $o->{STRUCT} ||= {
              '.macros' => '',
              '.xs' => '',
              '.any' => 0,
              '.all' => 0,
             };
    $o->{ILSM}{AUTO_INCLUDE} ||= <<END;
#ifndef bool
#include <%iostream%>
#endif
extern "C" {
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#include "INLINE.h"
}
#ifdef bool
#undef bool
#include <%iostream%>
#endif


END


# Don't edit this here-doc.  These are set by Makefile.PL.  Override
# by supplying undefs in an AUTO_INCLUDE configuration.
my $flavor_defs =  <<END_FLAVOR_DEFINITIONS;

#define __INLINE_CPP_STANDARD_HEADERS 1
#define __INLINE_CPP_NAMESPACE_STD 1

END_FLAVOR_DEFINITIONS


    # Prepend the compiler flavor (Standard versus Legacy) #define's
    # to the AUTO_INCLUDE boilerplate.  We prepend because that way
    # it's easy for a user to #undef them in a custom-supplied
    # AUTO_INCLUDE.  May be useful for overriding errant defaults,
    # or testing.
    $o->{ILSM}{AUTO_INCLUDE} =
        $flavor_defs . $o->{ILSM}{AUTO_INCLUDE};


    $o->{ILSM}{PRESERVE_ELLIPSIS} = 0
      unless defined $o->{ILSM}{PRESERVE_ELLIPSIS};

    # Filter out the parameters we treat differently than Inline::C
    my @propagate;
    while(@_) {
    my ($key, $value) = (shift, shift);
    if ($key eq 'LIBS') {
        $value = [$value] unless ref $value eq 'ARRAY';
        my $num = scalar @{$o->{ILSM}{MAKEFILE}{LIBS}} - 1;
        $o->{ILSM}{MAKEFILE}{LIBS}[$num] .= ' ' . $_
          for (@$value);
        next;
    }
    if ($key eq 'ALTLIBS') {
        $value = [$value] unless ref $value eq 'ARRAY';
        push @{$o->{ILSM}{MAKEFILE}{LIBS}}, '';
        my $num = scalar @{$o->{ILSM}{MAKEFILE}{LIBS}} - 1;
        $o->{ILSM}{MAKEFILE}{LIBS}[$num] .= ' ' . $_
          for (@$value);
        next;
    }
    if ($key eq 'PRESERVE_ELLIPSIS' or
        $key eq 'STD_IOSTREAM') {
        croak "Argument to $key must be 0 or 1"
          unless $value == 0 or $value == 1;
        $o->{ILSM}{$key} = $value;
        next;
    }
    push @propagate, $key, $value;
    }

    # Replace %iostream% with the correct iostream library

    # It is critical that the following line not have its "comment"
    # altered: Makefile.PL finds the line and alters the iostream name.
 my $iostream = 'iostream'; # default iostream filename

    $o->{ILSM}{AUTO_INCLUDE} =~ s|%iostream%|$iostream|g;

    # Forward all unknown requests up to Inline::C
    $o->SUPER::validate(@propagate) if @propagate;
}

#============================================================================
# Print a small report if PRINT_INFO option is set
#============================================================================
sub info {
    my $o = shift;
    my $info = "";

    $o->parse unless $o->{ILSM}{parser};
    my $data = $o->{ILSM}{parser}{data};

    my (@class, @func);
    if (defined $data->{classes}) {
    for my $class (sort @{$data->{classes}}) {
        my @parents = grep { $_->{thing} eq 'inherits' }
          @{$data->{class}{$class}};
        push @class, "\tclass $class";
        push @class, (" : "
              . join (', ',
                  map { $_->{scope} . " " . $_->{name} } @parents)
             ) if @parents;
        push @class, " {\n";
        for my $thing (sort { $a->{name} cmp $b->{name} }
               @{$data->{class}{$class}}) {
        my ($name, $scope, $type) = @{$thing}{qw(name scope thing)};
        next unless $scope eq 'public' and $type eq 'method';
        next unless $o->check_type(
            $thing,
            $name eq $class,
            $name eq "~$class",
        );
        my $rtype = $thing->{rtype} || "";
        push @class, "\t\t$rtype" . ($rtype ? " " : "");
        push @class, $class . "::$name(";
        my @args = grep { $_->{name} ne '...' } @{$thing->{args}};
        my $ellipsis = (scalar @{$thing->{args}} - scalar @args) != 0;
        push @class, join ', ', (map "$_->{type} $_->{name}", @args),
          $ellipsis ? "..." : ();
        push @class, ");\n";
        }
        push @class, "\t};\n"
    }
    }
    if (defined $data->{functions}) {
    for my $function (sort @{$data->{functions}}) {
        my $func = $data->{function}{$function};
        next if $function =~ /::/;
        next unless $o->check_type($func, 0, 0);
        push @func, "\t" . $func->{rtype} . " ";
        push @func, $func->{name} . "(";
        my @args = grep { $_->{name} ne '...' } @{$func->{args}};
        my $ellipsis = (scalar @{$func->{args}} - scalar @args) != 0;
        push @func, join ', ', (map "$_->{type} $_->{name}", @args),
          $ellipsis ? "..." : ();
        push @func, ");\n";
    }
    }

    # Report:
    {
    local $" = '';
    $info .= "The following classes have been bound to Perl:\n@class\n"
        if @class;
    $info .= "The following functions have been bound to Perl:\n@func\n"
        if @func;
    }
    $info .= Inline::Struct::info($o) if $o->{STRUCT}{'.any'};
    return $info;
}

#============================================================================
# Generate a C++ parser
#============================================================================
sub get_parser {
    my $o = shift;
    my $grammar = Inline::CPP::grammar::grammar()
        or croak "Can't find C++ grammar\n";
    $::RD_HINT++;
    require Parse::RecDescent;
    my $parser = Parse::RecDescent->new($grammar);
    $parser->{data}{typeconv} = $o->{ILSM}{typeconv};
    $parser->{ILSM} = $o->{ILSM}; # give parser access to config options
    return $parser;
}

#============================================================================
# Intercept xs_generate and create the typemap file
#============================================================================
sub xs_generate {
    my $o = shift;
    $o->write_typemap;
    $o->SUPER::xs_generate;
}

#============================================================================
# Return bindings for functions and classes
#============================================================================
sub xs_bindings {
    my $o = shift;
    my ($pkg, $module) = @{$o->{API}}{qw(pkg module modfname)};
    my $data = $o->{ILSM}{parser}{data};
    my @XS;

    warn("Warning: No Inline C++ functions or classes bound to Perl\n" .
     "Check your C++ for Inline compatibility.\n\n")
      if ((not defined $data->{classes})
      and (not defined $data->{functions})
      and ($^W));

    for my $class (@{$data->{classes}}) {
    my $proper_pkg = $pkg . "::$class";
    # Set up the proper namespace
    push @XS, <<END;

MODULE = $module        PACKAGE = $proper_pkg

PROTOTYPES: DISABLE

END

    my ($ctor, $dtor, $abstract) = (0, 0, 0);
    for my $thing (@{$data->{class}{$class}}) {
        my ($name, $scope, $type) = @{$thing}{qw|name scope thing|};

        # Let Perl handle inheritance
        if ($type eq 'inherits' and $scope eq 'public') {
        $o->{ILSM}{XS}{BOOT} ||= '';
        my $ISA_name = "${pkg}::${class}::ISA";
        my $parent = "${pkg}::${name}";
        $o->{ILSM}{XS}{BOOT} .= <<END;
{
#ifndef get_av
    AV *isa = perl_get_av("$ISA_name", 1);
#else
    AV *isa = get_av("$ISA_name", 1);
#endif
    av_push(isa, newSVpv("$parent", 0));
}
END
        }

        # Get/set methods will go here:

        # Cases we skip:
        $abstract ||= ($type eq 'method' and $thing->{abstract});
        next if ($type eq 'method' and $thing->{abstract});
        next if $scope ne 'public';
        if ($type eq 'enum') {
        $o->{ILSM}{XS}{BOOT} .= make_enum($proper_pkg, $name,
                          $thing->{body});
        } elsif ($type eq 'method') {
        next if $name =~ /operator/;
        # generate an XS wrapper
        $ctor ||= ($name eq $class);
        $dtor ||= ($name eq "~$class");
        push @XS, $o->wrap($thing, $name, $class);
        }
    }

    # Provide default constructor and destructor:
    push @XS, <<END unless ($ctor or $abstract);
$class *
${class}::new()

END
    push @XS, <<END unless ($dtor or $abstract);
void
${class}::DESTROY()

END
    }

    my $prefix = (
    $o->{ILSM}{XS}{PREFIX}
    ? "PREFIX = $o->{ILSM}{XS}{PREFIX}"
    : ''
    );
    push @XS, <<END;
MODULE = $module        PACKAGE = $pkg  $prefix

PROTOTYPES: DISABLE

END

    for my $function (@{$data->{functions}}) {
    # lose constructor defs outside class decls (and "implicit int")
    next if $data->{function}{$function}{rtype} eq '';
    next if $data->{function}{$function}{rtype} =~ 'static'; # special case
    next if $function =~ /::/; # XXX: skip member functions?
    next if $function =~ /operator/; # and operators.
    push @XS, $o->wrap($data->{function}{$function}, $function);
    }

    for (@{$data->{enums}}) {
    # Global enums.
    $o->{ILSM}{XS}{BOOT} .= make_enum($pkg, @$_{qw(name body)});
    }
#     print "BOOT = \n", $o->{ILSM}{XS}{BOOT};

    return join '', @XS;
}

#============================================================================
# Generate an XS wrapper around anything: a C++ method or function
#============================================================================
sub wrap {
    my $o = shift;
    my $thing = shift;
    my $name = shift;
    my $class = shift || "";
    my $t = ' ' x 4; # indents in 4-space increments.

    my (@XS, @PREINIT, @CODE);
    my ($ctor, $dtor) = (0, 0);

    if ($name eq $class) {  # ctor
    push @XS, $class . " *\n" . $class . "::new";
    $ctor = 1;
    }
    elsif ($name eq "~$class") { # dtor
    push @XS, "void\n$class" . "::DESTROY";
    $dtor = 1;
    }
    elsif ($class) {        # method
    push @XS, "$thing->{rtype}\n$class" . "::$thing->{name}";
    }
    else {          # function
    push @XS, "$thing->{rtype}\n$thing->{name}";
    }

    return '' unless $o->check_type($thing, $ctor, $dtor);

    # Filter out optional subroutine arguments
    my (@args, @opts, $ellipsis, $void);
    $_->{optional} ? push @opts, $_ : push @args, $_ for @{$thing->{args}};
    $ellipsis = pop @args if (@args and $args[-1]{name} eq '...');
    $void = ($thing->{rtype} and $thing->{rtype} eq 'void');
    push @XS, join '', (
    "(",
    join(
        ", ",
        (map {$_->{name}} @args),
        (scalar @opts or $ellipsis) ? '...' : ()
    ),
    ")\n",
    );

    # Declare the non-optional arguments for XS type-checking
    push @XS, "\t$_->{type}\t$_->{name}\n" for @args;

    # Wrap "complicated" subs in stack-checking code
    if ($void or $ellipsis) {
    push @PREINIT, "\tI32 *\t__temp_markstack_ptr;\n";
    push @CODE, "\t__temp_markstack_ptr = PL_markstack_ptr++;\n";
    }

    if (@opts) {
    push @PREINIT, "\t$_->{type}\t$_->{name};\n" for @opts;
    push @CODE, "switch(items" . ($class ? '-1' : '') . ") {\n";

    my $offset = scalar @args; # which is the first optional?
    my $total = $offset + scalar @opts;
    for (my $i=$offset; $i<$total; $i++) {
        push @CODE, "case " . ($i+1) . ":\n";
        my @tmp;
        for (my $j=$offset; $j<=$i; $j++) {
        my $targ = $opts[$j-$offset]{name};
        my $type = $opts[$j-$offset]{type};
        my $src  = "ST($j)";
        my $conv = $o->typeconv($targ,$src,$type,'input_expr');
        push @CODE, $conv . ";\n";
        push @tmp, $targ;
        }
        push @CODE, "\tRETVAL = " unless $void;
        push @CODE, call_or_instantiate(
        $name, $ctor, $dtor, $class, $thing->{rconst},
        $thing->{rtype}, (map { $_->{name} } @args), @tmp
        );
        push @CODE, "\tbreak; /* case " . ($i+1) . " */\n";
    }
    push @CODE, "default:\n";
    push @CODE, "\tRETVAL = " unless $void;
    push @CODE, call_or_instantiate(
        $name, $ctor, $dtor, $class, $thing->{rconst}, $thing->{rtype},
        map { $_->{name} } @args
    );
    push @CODE, "} /* switch(items) */ \n";
    }
    elsif ($void) {
    push @CODE, "\t";
    push @CODE, call_or_instantiate(
        $name, $ctor, $dtor, $class, 0, '', map { $_->{name} } @args
    );
    }
    elsif ($ellipsis or $thing->{rconst}) {
    push @CODE, "\t";
    push @CODE, "RETVAL = ";
    push @CODE, call_or_instantiate(
        $name, $ctor, $dtor, $class, $thing->{rconst}, $thing->{rtype},
        map { $_->{name} } @args
    );
    }
    if ($void) {
    push @CODE, <<'END';
        if (PL_markstack_ptr != __temp_markstack_ptr) {
          /* truly void, because dXSARGS not invoked */
          PL_markstack_ptr = __temp_markstack_ptr;
          XSRETURN_EMPTY; /* return empty stack */
        }
        /* must have used dXSARGS; list context implied */
        return; /* assume stack size is correct */
END
    }
    elsif ($ellipsis) {
    push @CODE, "\tPL_markstack_ptr = __temp_markstack_ptr;\n";
    }

    # The actual function:
    local $" = '';
    push @XS, "${t}PREINIT:\n@PREINIT" if @PREINIT;
    push @XS, $t;
    push @XS, "PP" if $void and @CODE;
    push @XS, "CODE:\n@CODE" if @CODE;
    push @XS, "${t}OUTPUT:\nRETVAL\n" if @CODE and not $void;
    push @XS, "\n";
    return "@XS";
}

sub call_or_instantiate {
    my ($name, $ctor, $dtor, $class, $const, $type, @args) = @_;

    # Create an rvalue (which might be const-casted later).
    my $rval = '';
    $rval .= "new " if $ctor;
    $rval .= "delete " if $dtor;
    $rval .= "THIS->" if ($class and not ($ctor or $dtor));
    $rval .= "$name(" . join (',', @args) . ")";

    return const_cast($rval, $const, $type) . ";\n";
}

sub const_cast {
    my $value = shift;
    my $const = shift;
    my $type  = shift;
    return $value unless $const and $type =~ /\*|\&/;
    return "const_cast<$type>($value)";
}

sub write_typemap {
    my $o = shift;
    my $filename = "$o->{API}{build_dir}/CPP.map";
    my $type_kind = $o->{ILSM}{typeconv}{type_kind};
    my $typemap = "";
    $typemap .= $_ . "\t"x2 . $TYPEMAP_KIND . "\n"
      for grep { $type_kind->{$_} eq $TYPEMAP_KIND } keys %$type_kind;
    return unless length $typemap;
    open TYPEMAP, "> $filename"
      or croak "Error: Can't write to $filename: $!";
    print TYPEMAP <<END;
TYPEMAP
$typemap
OUTPUT
$TYPEMAP_KIND
$o->{ILSM}{typeconv}{output_expr}{$TYPEMAP_KIND}
INPUT
$TYPEMAP_KIND
$o->{ILSM}{typeconv}{input_expr}{$TYPEMAP_KIND}
END
    close TYPEMAP;
    $o->validate(TYPEMAPS => $filename);
}

# Generate type conversion code: perl2c or c2perl.
sub typeconv {
    my $o = shift;
    my $var = shift;
    my $arg = shift;
    my $type = shift;
    my $dir = shift;
    my $preproc = shift;
    my $tkind = $o->{ILSM}{typeconv}{type_kind}{$type};
    my $ret;
    {
        no strict;
        $ret =
            eval qq{qq{$o->{ILSM}{typeconv}{$dir}{$tkind}}};
    }
    chomp $ret;
    $ret =~ s/\n/\\\n/g if $preproc;
    return $ret;
}

# Verify that the return type and all arguments can be bound to Perl.
sub check_type {
    my $o = shift;
    my ($thing, $ctor, $dtor) = @_;
    my $badtype;

    # strip "useless" modifiers so the type is found in typemap:
    BADTYPE: while (1) {
    if (!($ctor || $dtor)) {
        my $t = $thing->{rtype};
        $t =~ s/^(\s|const|virtual|static)+//g;
        if ($t ne 'void' && !$o->typeconv('', '', $t, 'output_expr')) {
        $badtype = $t;
        last BADTYPE;
        }
    }
    foreach (map { $_->{type} } @{$thing->{args}}) {
        s/^(const|\s)+//go;
        if ($_ ne '...' && !$o->typeconv('', '', $_, 'input_expr')) {
        $badtype = $_;
        last BADTYPE;
        }
    }
    return 1;
    }
    # I don't really like this verbosity. This is what 'info' is for. Maybe we
    # should ask Brian for an Inline=DEBUG option.
    warn (
    "No typemap for type $badtype. " .
    "Skipping $thing->{rtype} $thing->{name}(" .
    join(', ', map { $_->{type} } @{$thing->{args}}) .
    ")\n"
    ) if 0;
    return 0;
}

# Generate boot-code for enumeration constants:
sub make_enum {
    my ($class, $name, $body) = @_;
    my @enum;
    push @enum, <<END;
\t{
\t    HV * pkg = gv_stashpv(\"$class\", 1);
\t    if (pkg == NULL)
\t        croak("Can't find package '$class'\\n");
END
    my $val = 0;
    foreach (@$body) {
    my ($k, $v) = @$_;
    $val = $v if defined $v;
    push @enum, <<END;
\tnewCONSTSUB(pkg, \"$k\", newSViv($val));
END
    ++$val;
    }
    push @enum, <<END;
\t}
END
    return join '', @enum;
}

1;

__END__
