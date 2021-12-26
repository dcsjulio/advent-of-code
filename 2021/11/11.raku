#!/usr/bin/env raku

multi sub MAIN(Bool :$tests where !*) {
    say 'Solution 1: ' ~ shining parse-input('input'.IO.lines), 100;
    say 'Solution 2: ' ~ shining parse-input('input'.IO.lines);
}

sub parse-input($lines) {
    $lines.map({ [ |.comb>>.Int ] }).list
}

sub increase-brightness($matrix) {
    increase $matrix, |$_ for ^$matrix X ^$matrix
}

sub increase($matrix, $y, $x) {
    $matrix[$y][$x] = $matrix[$y][$x].succ min 10
}

sub get-by-brightness($matrix, $brightness) {
    (^$matrix X ^$matrix).grep: { $matrix[.head][.tail] == $brightness }
}

sub neighbours($y, $x, $matrix) {
    ((-1, 0, 1) X (-1, 0, 1))
            .grep( { $^point !~~ (0, 0) } )
            .map(  { eager $^point.list Z+ ($y, $x) } )
            .grep( { $^point ~~ (^$matrix, ^$matrix) } )
            .grep( { $matrix[.head][.tail] < 10 } )
}

sub shining($matrix, $levels = ∞) {
    my $shined = 0;
    for ^$levels -> $step {
        next-step $matrix;
        my $shining = elems get-by-brightness $matrix, 0;
        if $shining == $matrix.elems ** 2 {
            return $step.succ
        } else {
            $shined += $shining;
        }
    }
    $shined
}

sub next-step($matrix) {
    increase-brightness $matrix;
    while get-by-brightness($matrix, 10).elems > 0 {
        my @shined-by = get-shined-by($matrix);
        change-brightness-all $matrix, from => 10, to => 11;
        if @shined-by.elems > 0 {
            increase $matrix, |$_ for @shined-by;
        }
    }
    change-brightness-all $matrix, from => 10, to => 0;
    change-brightness-all $matrix, from => 11, to => 0;
}

sub change-brightness-all($matrix, :$from, :$to) {
    $matrix[.head][.tail] = $to for get-by-brightness $matrix, $from
}

sub get-shined-by($matrix) {
    get-by-brightness($matrix, 10).map: { |neighbours |$_, $matrix }
}

#################################################
##################### TESTS #####################
#################################################

multi sub MAIN(Bool :$tests where *) {
    use Test;

    say "Running day11 tests...";

    plan 15;

    my ($input, $test, $result, $matrix);

    $test = 'Can parse simple input';
    $input = ('1',);
    $result = ([1,],);
    is-deeply parse-input($input), $result, $test;

    $test = 'Can parse a more complex input';
    $input = ('12', '34');
    $result = (
    [1, 2],
    [3, 4]);
    is-deeply parse-input($input), $result, $test;

    $test = 'Can increase brightness';
    $input = (
    [1, 2],
    [3, 4]);
    $result = (
    [2, 3],
    [4, 5]);
    increase-brightness $input;
    is-deeply $input, $result, $test;

    $test = 'Can get next to increase';
    $input = (
    [1, 9],
    [9, 4]);
    $result = ((0, 1), (1, 0));
    is-deeply get-by-brightness($input, 9), $result, $test;

    $test = 'Can get neighbours';
    $input = (1, 2);
    $result = ((0, 1), (0, 2), (0, 3), (1, 1), (1, 3), (2, 1), (2, 2), (2, 3));
    is-deeply neighbours(|$input, (1, 1, 1, 1) xx 4), $result, $test;

    $test = 'Can do next step 1';
    $input = (
    [1, 9],
    [9, 4]);
    $result = (
    [4, 0],
    [0, 7]);
    next-step $input;
    is-deeply $input, $result, $test;


    $test = 'Can do next step 2';
    $result = (
    [5, 1],
    [1, 8]);
    next-step $input;
    is-deeply $input, $result, $test;

    $test = 'Can do next step 3';
    $result = (
    [6, 2],
    [2, 9]);
    next-step $input;
    is-deeply $input, $result, $test;

    $test = 'Can do next step 4';
    $result = (
    [8, 4],
    [4, 0]);
    next-step $input;
    is-deeply $input, $result, $test;

    $test = 'Can do next step 5';
    $result = (
    [9, 5],
    [5, 1]);
    next-step $input;
    is-deeply $input, $result, $test;

    $test = 'Can do next step 6';
    $result = (
    [0, 7],
    [7, 3]);
    next-step $input;
    is-deeply $input, $result, $test;

    $test = 'Can do next step for simple example case';
    $input = (
    [1, 1, 1, 1, 1],
    [1, 9, 9, 9, 1],
    [1, 9, 1, 9, 1],
    [1, 9, 9, 9, 1],
    [1, 1, 1, 1, 1]);
    $result = (
    [3, 4, 5, 4, 3],
    [4, 0, 0, 0, 4],
    [5, 0, 0, 0, 5],
    [4, 0, 0, 0, 4],
    [3, 4, 5, 4, 3]);
    next-step $input;
    is-deeply $input, $result, $test;

    $test = 'Can do next step (2) for simple example case';
    $result = (
    [4, 5, 6, 5, 4],
    [5, 1, 1, 1, 5],
    [6, 1, 1, 1, 6],
    [5, 1, 1, 1, 5],
    [4, 5, 6, 5, 4]);
    next-step $input;
    is-deeply $input, $result, $test;

    $test = 'Can solve first example';
    $input = q:to/END/;
    6594254334
    3856965822
    6375667284
    7252447257
    7468496589
    5278635756
    3287952832
    7993992245
    5957959665
    6394862637
    END
    $result = 204;
    $matrix = parse-input($input.lines);
    is shining($matrix, 9), $result, $test;

    $test = 'Can solve second example';
    $input = q:to/END/;
    5483143223
    2745854711
    5264556173
    6141336146
    6357385478
    4167524645
    2176841721
    6882881134
    4846848554
    5283751526
    END
    $result = 195;
    $matrix = parse-input($input.lines);
    is shining($matrix), $result, $test;
}
