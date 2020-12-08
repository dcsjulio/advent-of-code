#!/usr/bin/env raku

use experimental :cached;

my @bags = 'input'.IO.lines;

## CASE 1: ##

sub get-parents($bag-name) is cached {
    my $regex = rx/ <?wb> contain <?wb> .* <?wb> $bag-name <?wb> /;
    @bags.grep($regex).map(*.words[^2].join: ' ').unique.list
}

sub get-top($bag-name) {
    my @parents = get-parents $bag-name;
    (|@parents, @parents.map(&get-top))
}

say 'Case 1: ' ~ get-top('shiny gold').flat.unique.elems;

## CASE 2: ##

sub count-and-child($line) {
    state $regex = /' contain ' [(\d+) ' ' (\w+ ' ' \w+) ' ' bags?]+ % ', '/;
    $line ~~ $regex ?? ($0 Z $1) !! ((0, ''),)
}

sub get-childs($bag-name) {
    @bags.grep(/^$bag-name <?wb>/).map(&count-and-child).head
}

sub count-childs($bag-name) {
    [+] get-childs($bag-name)
            .grep( *.head > 0 )
            .map({ .head * count-childs(.tail).succ })
}

say 'Case 2: ' ~ count-childs('shiny gold');

