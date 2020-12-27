#!/usr/bin/env raku

sub process($input, $iterations) {
    my @input-list := $input.split(',').list;

    my %seen-num = @input-list.map: * => 1;
    my %positions = @input-list.antipairs;
    my $pos = @input-list.elems.pred;
    my $last = @input-list.tail;

    for ^($iterations - @input-list.elems) {
        my $next = %seen-num{$last} < 2 ?? 0 !! $pos - %positions{$last};
        %seen-num{$next}++;
        %seen-num{$last}++;
        %positions{$last} = $pos++;
        $last = $next;
    }

    $last
}

say 'CASE 1: ' ~ process '12,1,16,3,11,0', 2020;

say 'CASE 2: ' ~ process '12,1,16,3,11,0', 30_000_000;

