#!/usr/bin/env raku

sub get-id($boarding-pass) {
    $boarding-pass.trans('BFLR' => '1001').parse-base: 2
}

my @sorted-passes = 'input'.IO.lines.map(&get-id).sort;

say 'Solution 1: ' ~ @sorted-passes.tail;

say 'Solution 2: ' ~ @sorted-passes
        .rotor(2 => -1)
        .grep({ -1 != [-] @^them })
        .map: *.head.succ;
