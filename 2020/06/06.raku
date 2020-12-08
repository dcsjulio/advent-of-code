#!/usr/bin/env raku

my @blocks = 'input'.IO.slurp.split("\n\n");

say 'Solution 1: ' ~ @blocks.map(*.comb.unique.grep(* ne "\n").elems).sum;

say 'Solution 2: ' ~ @blocks.map({ elems [∩] .chomp.split("\n").map(*.comb) }).sum;
