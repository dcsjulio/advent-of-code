#!/usr/bin/env raku

sub get-id($boarding-pass) {
    $boarding-pass.trans('BFLR' => '1001') andthen "0b$_".Int
}

my @sorted-passes = 'input'.IO.lines.map({ get-id $_ }).sort;

say 'Solution 1: ' ~ @sorted-passes.tail;

say 'Solution 2: ' ~ @sorted-passes
        .rotor(2 => -1)
        .grep({ -1 != [-] @^them })
        .map: *.head.succ;
