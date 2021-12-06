#!/usr/bin/env raku

sub count-levels(@items) {
    elems @items.rotor(2 => -1).map({ .tail - .head }).grep: * > 0
}

my @input := 'input'.IO.lines>>.Int;

say 'Solution 1: ' ~ count-levels @input;
say 'Solution 2: ' ~ count-levels @input.rotor(3 => -2).map({ [+] $_ });
