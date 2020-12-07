#!/usr/bin/env raku

my $map = 'input'.IO.slurp;
my $w = $map.lines.head.chars;

my @slopes := (3, 1), (1, 1), (5, 1), (7, 1), (1, 2);

sub get-sum($right, $down) {
    my $x = 0;
    ($map ~~ m:g/:r ^^ .**{$x} [\# {make 1} | \. {make 0}] [\S*\s+]**{$down} {$x=($x+$right)%$w} /).map(*.made).sum
}

my @results = @slopes.map({get-sum |@^from});

say "CASE 1: {@results.head}";
say "CASE 2: {[*] @results}";
