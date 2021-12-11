#!/usr/bin/env raku

multi sub MAIN(Bool :$tests where !*) {
    my $input = 'input'.IO.slurp;
    say 'Solution 1: ' ~ solution($input, :filter);
    say 'Solution 2: ' ~ solution($input);
}

sub solution($input, :$filter) {
    my %seen-points;
    my @vectors = remove-data($input, :$filter).lines.map: &parse-line;
    for @vectors -> @vector {
        for get-middle-points(@vector) -> $point {
            save-point %seen-points, $point;
        }
    }
    count-overlapped %seen-points
}

sub remove-data($content, :$filter) {
    $content.subst: /:r
        ^^  (\d+) ',' (\d+) ' -> ' (\d+) ',' (\d+) [\n|$]
            <?{ $filter && $0 != $2 and $1 != $3 }> /, '', :g
}

sub parse-line($line) {
    $line.split(/\D+:/).rotor: 2
}

sub get-middle-points($vector) {
    my @ranges = ([Z-] $vector).map: { 0...$_ };
    my $is-diagonal = [==] @ranges.map: *.elems;
    my @path = $is-diagonal ?? [Z] @ranges !! [X] @ranges;
    my $points = (($vector.head,) X @path);
    $points.map({ [Z-] $_ }).map: { .join: ',' }
}

sub save-point(%counter, $point) {
    %counter{$point}++
}

sub count-overlapped(%counter) {
    elems %counter.pairs.grep: { .value > 1 }
}

#################################################
##################### TESTS #####################
#################################################

multi sub MAIN(Bool :$tests where *) {
    use Test;

    say "Running day05 tests...";

    plan 17;

    my ($test, $input, $result);

    $test = 'Keeps single line - same y';
    $input = '0,9 -> 5,9';
    is remove-data($input, :filter), $input, $test;

    $test = 'Keeps single line - same x';
    $input = '0,9 -> 0,1';
    is remove-data($input, :filter), $input, $test;

    $test = 'Keeps single line with newline';
    $input = "0,9 -> 5,9\n";
    is remove-data($input, :filter), $input, $test;

    $test = 'Filters single';
    $input = '0,9 -> 5,8';
    is remove-data($input, :filter), '', $test;

    my $example = q:to/END/;
    0,9 -> 5,9
    8,0 -> 0,8
    9,4 -> 3,4
    2,2 -> 2,1
    7,0 -> 7,4
    6,4 -> 2,0
    0,9 -> 2,9
    3,4 -> 1,4
    0,0 -> 8,8
    5,5 -> 8,2
    END

    my $example-output = q:to/END/;
    0,9 -> 5,9
    9,4 -> 3,4
    2,2 -> 2,1
    7,0 -> 7,4
    0,9 -> 2,9
    3,4 -> 1,4
    END

    $test = 'Can filter example input';
    is remove-data($example, :filter), $example-output, $test;

    $test = 'Can parse line';
    $input = '7,0 -> 7,4';
    is parse-line($input), ((7,0),(7,4)), $test;

    $test = 'Can parse line with new line';
    $input = "7,5 -> 2,4\n";
    is parse-line($input), ((7,5),(2,4)), $test;

    $test = 'Can get vertical middle points';
    $input = ((7,0),(7,4));
    $result = ('7,0', '7,1', '7,2', '7,3', '7,4');
    is get-middle-points($input), $result, $test;

    $test = 'Can get horizontal middle points';
    $input = ((42,6),(42,9));
    $result = ('42,6', '42,7', '42,8', '42,9');
    is get-middle-points($input), $result, $test;

    $test = 'Can get self point';
    $input = ((42,6),(42,6));
    $result = ('42,6');
    is get-middle-points($input), $result, $test;

    $test = 'Works with negative numbers';
    $input = ((-42,-6),(-42,-8));
    $result = ('-42,-6','-42,-7','-42,-8');
    is get-middle-points($input), $result, $test;

    my %counter;
    $test = 'Can add points';
    $input = ('-42,-6','-42,-7','-42,-8', '-42,-8', '-42,-9');
    for $input.list -> $point {
        save-point %counter, $point;
    }
    is-deeply %counter, {
        '-42,-6' => 1,
        '-42,-7' => 1,
        '-42,-8' => 2,
        '-42,-9' => 1,
    }, $test;

    $test = 'Can count overlapped';
    $result = 1;
    is count-overlapped(%counter), $result, $test;

    $test = 'Can solve first example';
    $result = 5;
    is solution($example, :filter), $result, $test;

    ## Case 2

    $example-output = q:to/END/;
    0,9 -> 5,9
    8,0 -> 0,8
    9,4 -> 3,4
    2,2 -> 2,1
    7,0 -> 7,4
    6,4 -> 2,0
    0,9 -> 2,9
    3,4 -> 1,4
    0,0 -> 8,8
    5,5 -> 8,2
    END

    $test = 'Doesn\'t filter diagonals';
    is remove-data($example), $example-output, $test;

    $test = 'Can get diagonal middle points';
    $input = ((1,1),(3,3));
    $result = ('1,1', '2,2', '3,3');
    is get-middle-points($input), $result, $test;

    $test = 'Can solve second example';
    $result = 12;
    is solution($example), $result, $test;
}
