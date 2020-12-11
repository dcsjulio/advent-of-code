#!/usr/bin/env raku

my @numbers = 0, |'input'.IO.lines>>.Int.sort;

## CASE 1: ##

my @diffs = @numbers.rotor(2 => -1).map({ .tail - .head });

say 'CASE 1: ' ~ @diffs.grep(* == 1).elems * @diffs.grep(* == 3).elems.succ;

## CASE 2: ##

multi states($length where * == 0) { 1 }
multi states($length where * <  0) { 0 }
multi states($length             ) { ($length - 3 ... $length - 1).map(&states).sum }

my $result = 1;

@diffs.join ~~ m:g/ (11+) {$result *= states $0.chars} /;

say 'CASE 2: ' ~ $result;

