#!/usr/bin/env raku

# First case, solved using Raku regexes

multi sub MAIN(Bool :$tests where !*) {
    my $input = 'input'.IO.slurp;
    say 'Solution 1: ' ~ get-risk-levels($input).sum;
}

sub get-risk-levels($input) {
    my $input-with-borders = add-borders $input;
    my $width = $input-with-borders.words.head.chars;
    ($input-with-borders.match: /:r
        :my ($prefix, $l, $x, $r);
        [ ^^ { $prefix = 0 } ]?
        (\d*?) (\d)(\d)(\d) <?{ $2 < $1 & $3 }>
        { $prefix += $0.chars; ($l, $x, $r) = $1, $2, $3 }
        <before .**{$width - 1} (\d) <?{$x < $0}>>
        <after <?{$x < $0}> (\d) .**{$width + 2}>
        { make $x.Int.succ; $prefix += 3 }
    /, :g).map: *.made
}

sub add-borders($input) {
    my $width = $input.words.head.chars + 2;
    my $h = "{'9' x $width}\n";
    $h ~ $input.subst(/^^|$$/, '9', :g) ~ $h
}

#################################################
##################### TESTS #####################
#################################################

multi sub MAIN(Bool :$tests where *) {
    use Test;

    say "Running day09 tests...";

    plan 8;

    my ($input, $test, $result);

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
}