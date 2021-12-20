#!/usr/bin/env raku

constant \SHIFT = ((-1, 0),(0, 1),(1, 0),(0, -1));

multi sub MAIN(Bool :$tests where !*) {
    my $input = 'input'.IO.slurp;
    say 'Solution 1: ' ~ [+] get-risk-levels $input;
    say 'Solution 2: ' ~ [*] find-top3-basins $input;
}

sub get-risk-levels($input) {
    my $w = $input.words.head.chars;
    my $h = $input.lines.elems;
    my $matrix = parse-input add-borders $input;
    ((1 ... $h) X (1 ... $w)).map({ get-risk $matrix, |$_ }).grep: * > 0
}

sub get-risk($matrix, $y, $x) {
    my $t = $matrix[$y - 1;$x    ];
    my $r = $matrix[$y    ;$x + 1];
    my $b = $matrix[$y + 1;$x    ];
    my $l = $matrix[$y    ;$x - 1];
    my $c = $matrix[$y    ;$x    ];
    $c < $t & $r & $b & $l ?? $c + 1 !! 0
}

sub find-top3-basins($input) {
    my $*matrix = parse-input add-borders $input;
    my %*seen;
    my $w = $*matrix.head.elems - 2;
    my $h = $*matrix.elems - 2;
    (((1 ... $h) X (1 ... $w)).map({ get-basin-size |$_ }).sort.reverse)[^3]
}

sub add-borders($input) {
    my $width = $input.words.head.chars + 2;
    my $h = "{'9' x $width}\n";
    $h ~ $input.subst(/^^|$$/, '9', :g) ~ $h
}

sub parse-input($input) {
    $input.words.map(*.comb>>.Int).list
}

multi get-basin-size($y, $x where $*matrix[$y;$x] == 9) { 0 }
multi get-basin-size($y, $x where so %*seen{"$y;$x"})   { 0 }
multi get-basin-size($y, $x) {
    %*seen{"$y;$x"} = True;
    [+] 1, |SHIFT.map: { get-basin-size |($_ Z+ $y, $x) }
}

#################################################
##################### TESTS #####################
#################################################

multi sub MAIN(Bool :$tests where *) {
    use Test;

    say "Running day09 tests...";

    plan 15;

    my ($input, $test, $result, $*matrix, %*seen, $y, $x);

    $test = 'Can parse input';
    $input = q:to/END/;
    789
    405
    923
    END
    $result = (
        (7, 8, 9),
        (4, 0, 5),
        (9, 2, 3),
    );
    is-deeply parse-input($input), $result, $test;

    $test = 'Can add borders input';
    $input = q:to/END/;
    789
    405
    923
    END
    $result = q:to/END/;
    99999
    97899
    94059
    99239
    99999
    END
    is add-borders($input), $result, $test;

    $test = 'Can get simple risk levels';
    $input = q:to/END/;
    789
    405
    923
    END
    $result = (1,);
    is-deeply get-risk-levels($input), $result, $test;

    $test = 'Can get simple risk levels, another number';
    $input = q:to/END/;
    999
    919
    999
    END
    $result = (2,);
    is-deeply get-risk-levels($input), $result, $test;

    $test = 'No risk level';
    $input = q:to/END/;
    111
    111
    111
    END
    $result = ();
    is-deeply get-risk-levels($input), $result, $test;

    $test = 'Almost no risk level';
    $input = q:to/END/;
    222
    212
    922
    END
    $result = (2,);
    is-deeply get-risk-levels($input), $result, $test;

    $test = 'Can get bigger risk levels';
    $input = q:to/END/;
    9999
    9999
    9919
    9999
    END
    $result = (2,);
    is-deeply get-risk-levels($input), $result, $test;

    $test = 'Can get bigger risk levels, several values';
    $input = q:to/END/;
    9999
    9199
    9919
    9999
    END
    $result = (2, 2);
    is-deeply get-risk-levels($input), $result, $test;

    $test = 'Can work with edges, small square';
    $input = q:to/END/;
    919
    999
    999
    END
    $result = (2,);
    is-deeply get-risk-levels($input), $result, $test;

    $test = 'Can solve first example';
    $input = q:to/END/;
    2199943210
    3987894921
    9856789892
    8767896789
    9899965678
    END
    $result = 15;
    is get-risk-levels($input).sum, $result, $test;

    $*matrix = (
        (9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9),
        (9, 2, 1, 9, 9, 9, 4, 3, 2, 1, 0, 9),
        (9, 3, 9, 8, 7, 8, 9, 4, 9, 2, 1, 9),
        (9, 9, 8, 5, 6, 7, 8, 9, 8, 9, 2, 9),
        (9, 8, 7, 6, 7, 8, 9, 6, 7, 8, 9, 9),
        (9, 9, 8, 9, 9, 9, 6, 5, 6, 7, 8, 9),
        (9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9)
    );

    $test = 'Can get example 1,2 basin';
    ($y, $x) = 1, 2;
    $result = 3;
    %*seen = {};
    is get-basin-size($y, $x), $result, $test;

    $test = 'Can gen example 1,10 basin';
    ($y, $x) = 1, 10;
    $result = 9;
    %*seen = {};
    is get-basin-size($y, $x), $result, $test;

    $test = 'Can gen example 3,3 basin';
    ($y, $x) = 3, 3;
    $result = 14;
    %*seen = {};
    is get-basin-size($y, $x), $result, $test;

    $test = 'Can gen example 5,7 basin';
    ($y, $x) = 5, 7;
    $result = 9;
    %*seen = {};
    is get-basin-size($y, $x), $result, $test;

    $test = 'Can solve first example';
    $result = 1134;
    is ([*] find-top3-basins($input)), $result, $test;
}