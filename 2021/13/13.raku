#!/usr/bin/env raku

multi sub MAIN(Bool :$tests where !*) {
    my $input := 'input'.IO.slurp;
    my %points = parse-points $input;
    my $folds = parse-folds $input;
    say 'Solution 1: ' ~ total-fold-just-once %points, $folds.head;
    say 'Solution 2: ' ~ secret-code %points, $folds[1 .. *];
}

sub parse-points($input) {
    my $list := $input.lines
            .grep({ .match: /^\d/ })
            .map({ .split(',').list });

    my %points;
    %points{.tail}{.head} = 'X' for $list;
    %points
}

sub parse-folds($input) {
    eager $input.lines
            .grep({ .match: /^fold/ })
            .map({ .match: /(.)'='(\d+)/ })
            .map({ $_[0].Str => $_[1].Int })
}

sub total-fold-just-once(%points, $fold) {
    fold-by %points, $fold;
    [+] %points.values.grep: *.values.elems
}

sub secret-code(%points, $folds) {
    fold-by %points, $_ for $folds.list;
    "\n" ~ draw-map %points
}

multi fold-by(%points, $fold where $fold.key eq 'x') {
    fold-any %points, $fold.value, -∞, { 2 * $fold.value - $_ }, { $_ }
}

multi fold-by(%points, $fold where $fold.key eq 'y') {
    fold-any %points, -∞, $fold.value, { $_ }, { 2 * $fold.value - $_ }
}

sub fold-any(%points, $x-min, $y-min, $x-new, $y-new) {
    my %points-org = %points;
    for %points-org.keys>>.Int.grep: * > $y-min -> $y {
        for %points-org{$y}.keys>>.Int.grep: * > $x-min -> $x {
            %points{$y}{$x}:delete;
            %points{$y}:delete unless %points{$y};
            %points{$y-new($y)}{$x-new($x)} = 'X';
        }
    }
}

sub draw-map(%points) {
    my $max-x := %points.values.map(*.keys).flat>>.Int.max;
    my $max-y := %points.keys>>.Int.max;
    my $map = '';
    for 0 .. $max-y -> $y {
        for 0 .. $max-x -> $x {
            $map ~= %points{$y}{$x} // ' ';
        }
        $map ~= "\n";
    }
    $map
}

#################################################
##################### TESTS #####################
#################################################

multi sub MAIN(Bool :$tests where *) {
    use Test;

    say "Running day13 tests...";

    plan 12;

    my ($input, $test, $result, %points, %result, $folds);

    $test = 'Can parse points, one line';
    $input = "1,1";
    %result = 1 => %(1 => 'X');
    is parse-points($input), %result, $test;

    $test = 'Can parse points, multiple lines';
    $input = "1,1\n2,2\n3,3";
    %result = 1 => %(1 => 'X'), 2 => %(2 => 'X'), 3 => %(3 => 'X');
    is parse-points($input), %result, $test;

    $test = 'Can parse points, repeat same x';
    $input = "1,1\n2,1";
    %result = 1 => %(1 => 'X', 2 => 'X');
    is parse-points($input), %result, $test;

    $test = 'Can parse points, multiple lines mixed with other data';
    $input = "foo\n1,1\nbar\n2,2\nfoobar\n3,3\nbarfoo";
    %result = 1 => %(1 => 'X'), 2 => %(2 => 'X'), 3 => %(3 => 'X');
    is parse-points($input), %result, $test;

    $test = 'Can parse folds, one line';
    $input = "fold along x=655";
    $result = (('X' => 655),);
    is parse-folds($input), $result, $test;

    $test = 'Can parse folds, multiple lines';
    $input = "fold along x=44\nfold along y=12\nfold along y=22";
    $result = (('X' => 44), ('y' => 12), ('y' => 22));
    is parse-folds($input), $result, $test;

    $test = 'Can parse folds, multiple lines mixed with other data';
    $input = "fold along x=44\nfoobar\nfold along y=22";
    $result = (('X' => 44), ('y' => 22));
    is parse-folds($input), $result, $test;

    $test = 'Can fold x, simple case';
    %points = 0 => %(2 => 'X');
    %result = 0 => %(0 => 'X');
    fold-by(%points, 'X' => 1);
    is %points, %result, $test;

    $test = 'Can fold x';
    %points = 0 => %(3 => 'X'), 1 => %(4 => 'X');
    %result = 0 => %(1 => 'X'), 1 => %(0 => 'X');
    fold-by(%points, 'X' => 2);
    is %points, %result, $test;

    $test = 'Can fold y, simple case';
    %points = 2 => %(0 => 'X');
    %result = 0 => %(0 => 'X');
    fold-by(%points, 'y' => 1);
    is %points, %result, $test;

    $test = 'Can fold y';
    %points = 3 => %(0 => 'X'), 4 => %(1 => 'X');
    %result = 1 => %(0 => 'X'), 0 => %(1 => 'X');
    fold-by(%points, 'y' => 2);
    is %points, %result, $test;

    $test = 'Can solve first example';
    $input = q:to/END/;
    6,10
    0,14
    9,10
    0,3
    10,4
    4,11
    6,0
    6,12
    4,1
    0,13
    10,12
    3,4
    3,0
    8,4
    1,10
    2,14
    8,10
    9,0

    fold along y=7
    fold along x=5
    END
    $result = 17;
    %points = parse-points $input;
    $folds = parse-folds $input;
    is total-fold-just-once(%points, $folds.head), $result, $test;
}