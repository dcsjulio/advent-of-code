#!/usr/bin/env raku

multi sub MAIN(Bool :$tests where !*) {
    my $input := parse-input 'input'.IO.slurp;
    say 'Solution 1: ';
    say 'Solution 2: ';
}

sub parse-input($input) {
    $input
}

#################################################
##################### TESTS #####################
#################################################

multi sub MAIN(Bool :$tests where *) {
    use Test;

    say "Running dayXX tests...";

    plan 1;

    my ($input, $test, $result);

    $test = 'Can whatever';
    $input = 'some input';
    $result = 'some result';
    is parse-input($input), $result, $test;

}
