package Inline::CPP::Parser::Pegex::AST;
use Pegex::Base;
extends 'Pegex::Tree';

sub initial {
    my ($self) = @_;
    $self->{data} = {};
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

sub got_function_declaration {
    my ($self, $got) = @_;
    my ($type, $name, $args) = @$got;
    my $rtype = $type->[0];
    my $i = 0;
    $args = [
        map {
            my ($type, $d1, $name) = @$_;
            $name ||= 'dummy' . ++$i;
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

sub handle_class_definition {
    my ($self, $got) = @_;
    my $class = $got->[0];
    my @parts;
    for my $part (@{$got->[1]}) { push @parts, @$_ for @$part }
    push @{$self->{data}{classes}}, $class
        unless defined $self->{data}{class}{$class};
    $self->{data}{class}{$class} = \@parts;
    Inline::CPP::Grammar::typemap($self, $class);
    [$class, \@parts];
}

1;
