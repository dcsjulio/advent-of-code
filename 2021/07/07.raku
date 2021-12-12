#!/usr/bin/env raku

multi sub MAIN(Bool :$tests where !*) {
    my $input = 'input'.IO.slurp;
    say 'Solution 1: ' ~ count-min-fuel $input, &cost-linear;
    say 'Solution 2: ' ~ count-min-fuel $input, &cost-non-linear;
}

sub count-min-fuel($input, $cost) {
    my @crabs = $input.split(',')>>.Int;
    (0 .. @crabs.max).map({ calculate-fuel @crabs, $_, $cost }).min
}

sub calculate-fuel(@positions, $target, $cost) {
    @positions.map({ $cost($_, $target) }).sum
}

sub cost-linear($position, $target) {
    abs($position - $target)
}

sub cost-non-linear($position, $target) {
    my $n = abs($position - $target);
    $n * $n.succ / 2
}

#################################################
##################### TESTS #####################
#################################################

multi sub MAIN(Bool :$tests where *) {
    use Test;

    say "Running day07 tests...";

    plan 12;

    my ($input, @positions, $target, $test, $result);

    $test = 'Can evaluate linear cost 1,8';
    $result = 7;
    is cost-linear(1, 8), $result, $test;

    $test = 'Can evaluate linear cost 8,1';
    $result = 7;
    is cost-linear(8, 1), $result, $test;

    $test = 'Can evaluate linear cost no movement';
    $result = 0;
    is cost-linear(8, 8), $result, $test;

    $test = 'Can count target fuel';
    @positions = [0, 1, 2, 3, 4];
    $target = 2;
    $result = 6;
    is calculate-fuel(@positions, $target, &cost-linear), $result, $test;

    $test = 'Can count another target fuel';
    @positions = [0, 1, 2, 3, 4];
    $target = 0;
    $result = 10;
    is calculate-fuel(@positions, $target, &cost-linear), $result, $test;

    $test = 'Can count min target fuel for first example';
    @positions = [16, 1, 2, 0, 4, 2, 7, 1, 2, 14];
    $target = 2;
    $result = 37;
    is calculate-fuel(@positions, $target, &cost-linear), $result, $test;

    $test = 'Can solve first example';
    $input = '16,1,2,0,4,2,7,1,2,14';
    $result = 37;
    is count-min-fuel($input, &cost-linear), $result, $test;

    $test = 'Can evaluate non-linear cost 4,2';
    $result = 3;
    is cost-non-linear(4, 2), $result, $test;

    $test = 'Can evaluate non-linear cost 2,4';
    $result = 3;
    is cost-non-linear(4, 2), $result, $test;

    $test = 'Can evaluate non-linear cost 8,1';
    $result = 28;
    is cost-non-linear(8, 1), $result, $test;

    $test = 'Can evaluate non-linear cost no movement';
    $result = 0;
    is cost-non-linear(8, 8), $result, $test;

    $test = 'Can solve second example';
    $input = '16,1,2,0,4,2,7,1,2,14';
    $result = 168;
    is count-min-fuel($input, &cost-non-linear), $result, $test;
}