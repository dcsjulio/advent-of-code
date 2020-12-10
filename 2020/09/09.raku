#!/usr/bin/env raku

constant BLOCK = 25;

my $file-content = 'input'.IO.slurp;
my @numbers = $file-content.lines>>.Int;

## CASE 1: ##

sub valid-pair($idx) {
    my @compared-to = @numbers[$idx - BLOCK .. $idx.pred].combinations(2).grep({.head != .tail}).map({.head + .tail});
    @numbers[$idx], so @numbers[$idx] == none @compared-to
}

my $weak = (BLOCK .. @numbers.elems.pred).map(&valid-pair).first(*.tail).map(*.head).head;

say 'CASE 1: ' ~ $weak;

## CASE 2: ##

@numbers.reverse.join("\n") ~~ m:g/^^[(\d+:) \s*: <?{$0.sum <= $weak}>] **? 2..* <?{$0.sum == $weak}> .*/ or die;

$0.head>>.Int.sort.list andthen say 'CASE 2: ' ~ .min + .max;
