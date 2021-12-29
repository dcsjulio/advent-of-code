#!/usr/bin/env raku

multi sub MAIN(Bool :$tests where !*) {
    my $paths := parse-input 'input'.IO.slurp;
    say 'Solution 1: ' ~ calculate-paths $paths, &simple-method;
    say 'Solution 2: ' ~ calculate-paths $paths, &complex-method;
}

sub simple-method($list, $last) {
    $last ∉ $list
}

sub complex-method($list, $last) {
    my $lower = eager $list.grep: { .lc eq $_ };
    $lower.unique.elems == $lower.elems || simple-method $list, $last
}

sub parse-input($input) {
    eager $input.lines.map: { eager .split: '-' }
}

sub calculate-paths($input-paths, $method) {
    my %cache = assemble-paths $input-paths;
    my $ended = 0;
    my $paths = (('start',),);
    while $paths {
        my $routes = add-path $paths, %cache, $method;
        $paths = $routes.grep: *.tail ne 'end';
        $ended += $routes.elems - $paths.elems;
    }
    $ended
}

sub assemble-paths($paths) {
    my %cache is default(());
    for $paths.list {
        if .head ne 'end' && .tail ne 'start' {
            %cache{.head} = (|%cache{.head}, .tail);
        }
        if .tail ne 'end' && .head ne 'start' {
            %cache{.tail} = (|%cache{.tail}, .head);
        }
    }
    %cache
}

sub add-path($current, %cache, $method) {
    eager $current
            .race.map({ slip |$_ X %cache{.tail}.list })
            .race.grep({ .tail.uc eq .tail || $method($_[0 .. *-2], .tail) })
}

#################################################
##################### TESTS #####################
#################################################

multi sub MAIN(Bool :$tests where *) {
    use Test;

    say "Running day12 tests...";

    plan 9;

    my ($input, $test, $result, $current, $new, %cache);

    $test = 'Can parse simple input';
    $input = 'LA-sn';
    $result = (('LA', 'sn'),);
    is-deeply parse-input($input), $result, $test;

    $test = 'Can parse more lines';
    $input = q:to/END/;
    LA-sn
    LA-mo
    LA-zs
    END

    $result = (('LA', 'sn'), ('LA', 'mo'), ('LA', 'zs'));
    is-deeply parse-input($input), $result, $test;

    $test = 'Can assemble path cache';
    $input = q:to/END/;
    aa-bb
    aa-cc
    cc-dd
    END
    %cache =
            'aa' => ('bb', 'cc'),
            'bb' => ('aa',),
            'cc' => ('aa', 'dd'),
            'dd' => ('cc',);
    is-deeply assemble-paths(parse-input $input), %cache, $test;

    $test = 'Can add next level, simple case';
    $input = (('XA', 'XB'),);
    %cache = assemble-paths(parse-input q:to/END/);
    XB-XC
    XB-XD
    END
    $result = (('XA', 'XB', 'XC'), ('XA', 'XB', 'XD'));
    is-deeply add-path($input, %cache, &simple-method), $result, $test;

    $test = 'Can add next level, skips lowercase repetition';
    $input = (('xa', 'xb', 'xc'),);
    %cache = assemble-paths(parse-input q:to/END/);
    xc-xa
    END
    $result = ();
    is-deeply add-path($input, %cache, &simple-method), $result, $test;

    $test = 'Can add next level, evals joining letters';
    $input = (('xa', 'xb', 'xc'), ('xa', 'xb'));
    %cache = assemble-paths(parse-input q:to/END/);
    xc-xd
    xb-end
    END
    $result = (('xa', 'xb', 'xc', 'xd'), ('xa', 'xb', 'end'));
    is-deeply add-path($input, %cache, &simple-method), $result, $test;

    $test = 'Can solve first small example';
    $input = q:to/END/;
    start-A
    start-b
    A-c
    A-b
    b-d
    A-end
    b-end
    END
    $result = 10;
    is calculate-paths(parse-input($input), &simple-method), $result, $test;

    $test = 'Can solve first example';
    $input = q:to/END/;
    dc-end
    HN-start
    start-kj
    dc-start
    dc-HN
    LN-dc
    HN-end
    kj-sa
    kj-HN
    kj-dc
    END
    $result = 19;
    is calculate-paths(parse-input($input), &simple-method), $result, $test;

    $test = 'Can solve second example';
    $input = q:to/END/;
    start-XA
    start-xb
    XA-xc
    XA-xb
    xb-xd
    XA-end
    xb-end
    END
    $result = 36;
    is calculate-paths(parse-input($input), &complex-method), $result, $test;
}
