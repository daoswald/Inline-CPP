package TestInlineCPP;

use Test::More();
use Pegex::Parser;
use Inline::CPP::Grammar;
use XXX;

sub test {
    my ($input) = @_;
    my $prd_data = prd_parse($input);
    my $parser = Pegex::Parser->new(
        grammar => Inline::CPP::Parser::Pegex::Grammar->new,
        receiver => Inline::CPP::Parser::Pegex::AST->new,
        # debug => 1,
    );
    my $pegex_data = $parser->parse($input);
    Test::More::is_deeply($prd_data, $pegex_data);
}

# A custom receiver class:
{
    package Inline::CPP::Parser::Pegex::AST;
    use Pegex::Base;
    extends 'Pegex::Tree';

    sub initial {
        my ($self) = @_;
        $self->{data} = {
            function => {},
            functions => [],
        };
    }

    sub final {
        my ($self) = @_;
        $self->{data};
    }

    sub got_function_definition {
        my ($self, $got) = @_;
        my ($type, $name, $args) = @$got;
        my $rtype = $type->[0];
        $args = [
            map {
                my ($type, $d1, $name) = @$_;
                {
                    name => $name,
                    type => $type,
                };
            } @$args
        ];
        $self->{data}{function}{$name} = {
            name => $name,
            rtype => $rtype,
            args => $args,
        };
        push @{$self->{data}{functions}}, $name;
    }
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

# A custom grammar class:
{
    package Inline::CPP::Parser::Pegex::Grammar;
    use Pegex::Base;
    extends 'Pegex::Grammar';

    use constant text => <<'...';
code: part+

# The only parts we care about are function definitions and declarations, but
# not those inside a comment.
part: =ALL (
  | comment
  | function_definition
  | function_declaration
  | anything_else
)

comment:
  /- SLASH SLASH [^ BREAK ]* BREAK / |
  /- SLASH STAR (: [^ STAR ]+ | STAR (! SLASH))* STAR SLASH ([ TAB ]*)? /

# int foo_ () { return -1; }\n
function_definition:
  rtype /( identifier )/ -
  LPAREN arg* % COMMA /- RPAREN - LCURLY -/

function_declaration:
  rtype /( identifier )/ -
  LPAREN arg_decl* % COMMA /- RPAREN - SEMI -/

rtype: /- (: rtype1 | rtype2 ) -/

rtype1: / modifier*( type_identifier ) - ( STAR*) /

rtype2: / modifier+ STAR*/

arg: /(: type - ( identifier)|( DOT DOT DOT ))/

arg_decl: /( type WS* identifier*| DOT DOT DOT )/

type: / WS*(: type1 | type2 ) WS* /

type1: / modifier*( type_identifier ) WS*( STAR* )/

type2: / modifier* STAR* /

modifier: /(: (:unsigned|long|extern|const)\b WS* )/

identifier: /(: WORD+ )/

type_identifier: /(: WORD+ )/

anything_else: / ANY* (: EOL | EOS ) /
c-plus-plus: (
  | function-definition
  | other-line
)*
...
}

test <<'...';

int foo ( int a ) { return a; }

...

