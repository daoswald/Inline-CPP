use strict; use warnings;
package TestInlineCPP;

BEGIN {
    $ENV{PERL_PEGEX_AUTO_COMPILE} = 'Inline::CPP::Parser::Pegex::Grammar';
}

use Test::More();
use YAML::XS;
use IO::All;

use Parse::RecDescent;
use Inline::CPP::Grammar;

use Pegex::Parser;
use Inline::CPP::Parser::Pegex::Grammar;
use Inline::CPP::Parser::Pegex::AST;

use base 'Exporter';
our @EXPORT = qw(test);

use XXX;

sub test {
    my ($input, $label) = @_;
    my $prd_data = prd_parse($input);
    my $parser = Pegex::Parser->new(
        grammar => Inline::CPP::Parser::Pegex::Grammar->new,
        receiver => Inline::CPP::Parser::Pegex::AST->new,
        debug => $ENV{DEBUG} # || 1,
    );
    my $pegex_data = $parser->parse($input);
    my $prd_dump = Dump $prd_data;
    my $pegex_dump = Dump $pegex_data;

    $label = "Pegex matches PRD: $label";
    if ($pegex_dump eq $prd_dump) {
        Test::More::pass $label;
    }
    else {
        Test::More::fail $label;
        io->file('got')->print($pegex_dump);
        io->file('want')->print($prd_dump);
        Test::More::diag(`diff -u want got`);
        unlink('want', 'got');
    }

    ($prd_data, $pegex_data);
}

sub prd_parse {
    my ($input) = @_;
    my $grammar = Inline::CPP::Grammar::grammar();
    my $parser = Parse::RecDescent->new( $grammar );
    $parser->code($input);
    my $data = $parser->{data};
    my $functions = $data->{function};
    for my $name (keys %$functions) {
        for my $arg (@{$functions->{$name}{args}}) {
            delete $arg->{offset};
        }
    }
    $parser->{data};
}

1;
