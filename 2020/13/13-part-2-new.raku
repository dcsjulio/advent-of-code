#!/usr/bin/env raku

my @input = 'input'.IO.lines;

my @buses = @input.tail.match(/:r \d+ {make +$/} | x {make 1}/, :g)>>.made;
my @data = (^@buses).map({ @buses[$_], $_ }).grep(*.head > 1).flat;

my $block = 1;
my $timestamp = 0;
for @data -> $bus, $offset {
    $timestamp += $block while ($timestamp + $offset) % $bus;
    $block = $block * $bus;
}
say $timestamp;
