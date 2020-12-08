#!/usr/bin/env raku

my @blocks = 'input'.IO.slurp.split("\n\n");

say 'Solution 1: ' ~ @blocks
        .map(*.comb.unique.grep(* ne "\n").elems)
        .sum;

my $repeated := rx/ :my $a; (\w) {$a = $0} <?after ^\S*> <?before [\S*:\s+:\S* $a]*: \S*\n? $> /;

say 'Solution 2: ' ~ @blocks.map({ elems m:g/$repeated/ }).sum;
