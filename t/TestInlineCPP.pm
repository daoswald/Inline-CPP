use strict; use warnings;
package TestInlineCPP;

use Test::More();

use Parse::RecDescent;
use Inline::CPP::Grammar;

use Pegex::Parser;
use Inline::CPP::Parser::Pegex::Grammar;
use Inline::CPP::Parser::Pegex::AST;

use base 'Exporter';
our @EXPORT = qw(test);

use XXX;

sub test {
    my ($input) = @_;
    my $prd_data = prd_parse($input);
    my $parser = Pegex::Parser->new(
        grammar => Inline::CPP::Parser::Pegex::Grammar->new,
        receiver => Inline::CPP::Parser::Pegex::AST->new,
        debug => $ENV{DEBUG} # || 1,
    );
    my $pegex_data = $parser->parse($input);
    Test::More::is_deeply($prd_data, $pegex_data);
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
