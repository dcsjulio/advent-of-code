#!/usr/bin/env raku

multi sub MAIN(Bool :$tests where !*) {
    my $input = 'input'.IO.slurp;
    say 'Solution 1: ' ~ count-lanternfish $input, 80;
    say 'Solution 2: ' ~ count-lanternfish $input, 256;
}

sub count-lanternfish($input, $days) {
    my @quantities = 0 xx 9;
    fill-quantities $input, @quantities;
    iterate(@quantities) for ^$days;
    [+] @quantities.values
}

sub fill-quantities($input, @quantities) {
    for $input.split: ',' -> $day {
        @quantities[$day]++;
    }
}

sub iterate(@quantities) {
    @quantities = @quantities.rotate;
    @quantities[6] += @quantities[8];
}

#################################################
##################### TESTS #####################
#################################################

multi sub MAIN(Bool :$tests where *) {
    use Test;

    say "Running day06 tests...";

    plan 14;

    my @quantities = 0 xx 9;

    my ($input, $test, $result);

    $test = 'Can parse input';
    $input = '1,1,1,2,2,2,3,3,3';
    $result = [0, 3, 3, 3, 0, 0, 0, 0, 0];
    fill-quantities($input, @quantities);
    is-deeply @quantities, $result, $test;

    $test = 'Can parse and add new numbers';
    $input = '0,6,6,6,6,8,8,8,8';
    $result = [1, 3, 3, 3, 0, 0, 4, 0, 4];
    fill-quantities($input, @quantities);
    is-deeply @quantities, $result, $test;

    $test = 'Can iterate 1';
    @quantities = [0, 1, 0, 0, 0, 0, 0, 0, 0];
    $result = [1, 0, 0, 0, 0, 0, 0, 0, 0];
    iterate(@quantities);
    is-deeply @quantities, $result, $test;

    $test = 'Can iterate 2';
    @quantities = [0, 0, 1, 0, 0, 0, 0, 0, 0];
    $result = [0, 1, 0, 0, 0, 0, 0, 0, 0];
    iterate(@quantities);
    is-deeply @quantities, $result, $test;

    $test = 'Can iterate 3';
    @quantities = [0, 0, 0, 1, 0, 0, 0, 0, 0];
    $result = [0, 0, 1, 0, 0, 0, 0, 0, 0];
    iterate(@quantities);
    is-deeply @quantities, $result, $test;

    $test = 'Can iterate 4';
    @quantities = [0, 0, 0, 0, 1, 0, 0, 0, 0];
    $result = [0, 0, 0, 1, 0, 0, 0, 0, 0];
    iterate(@quantities);
    is-deeply @quantities, $result, $test;

    $test = 'Can iterate 5';
    @quantities = [0, 0, 0, 0, 0, 1, 0, 0, 0];
    $result = [0, 0, 0, 0, 1, 0, 0, 0, 0];
    iterate(@quantities);
    is-deeply @quantities, $result, $test;

    $test = 'Can iterate 6';
    @quantities = [0, 0, 0, 0, 0, 0, 1, 0, 0];
    $result = [0, 0, 0, 0, 0, 1, 0, 0, 0];
    iterate(@quantities);
    is-deeply @quantities, $result, $test;

    $test = 'Can iterate 7';
    @quantities = [0, 0, 0, 0, 0, 0, 0, 1, 0];
    $result = [0, 0, 0, 0, 0, 0, 1, 0, 0];
    iterate(@quantities);
    is-deeply @quantities, $result, $test;

    $test = 'Can iterate 8';
    @quantities = [0, 0, 0, 0, 0, 0, 0, 0, 1];
    $result = [0, 0, 0, 0, 0, 0, 0, 1, 0];
    iterate(@quantities);
    is-deeply @quantities, $result, $test;

    $test = 'Can iterate 0';
    @quantities = [8, 0, 0, 0, 0, 0, 0, 6, 0];
    $result = [0, 0, 0, 0, 0, 0, 14, 0, 8];
    iterate(@quantities);
    is-deeply @quantities, $result, $test;

    $test = 'Passes example for 18 days';
    $input = '3,4,3,1,2';
    $result = 26;
    is count-lanternfish($input, 18), $result, $test;

    $test = 'Passes example for 80 days';
    $input = '3,4,3,1,2';
    $result = 5934;
    is count-lanternfish($input, 80), $result, $test;

    $test = 'Passes example for 256 days';
    $input = '3,4,3,1,2';
    $result = 26984457539;
    is count-lanternfish($input, 256), $result, $test;
}
