#!/usr/bin/env raku

my @input = 'input'.IO.lines;

my $ts = @input.head.Int;
my @buses := @input.tail.match(/:r \d+ {make +$/} | x {make 1}/, :g)>>.made;

## CASE 1 ##

my @departures = @buses.grep(*> 1)
        .map({ ($_ * ($ts div $_).succ) - $ts, $_ })
        .sort({ $^a.head <=> $^b.head });

say 'CASE 1: ' ~ [*] @departures.head.list;

## CASE 2 ##

my ($ts-offset, $ts-block) = calculate-min-block;

# ... However, with so many bus IDs in your list, surely the actual
# earliest timestamp will be larger than 100000000000000!

my $min-ts := 100000000000000;
my $max-ts := [*] @buses;

my @promises;
@promises.push: start { calculate-range $_ } for set-up-ranges;

await Promise.anyof: |@promises;

loop {
    for @promises -> $promise {
        if $promise.status eq 'Kept' && $promise.result > 0 {
            say 'CASE 2: ' ~ $promise.result;
            exit 0;
        }
    }
    sleep 1;
    last if 'Kept' eq all @promises>>.status;
}

######################################################################

sub set-up-ranges {
    my $slices := ($*KERNEL.cpu-cores * 4 / 3).Int;
    my $range-size := ($max-ts - $min-ts) div $slices;

    (^$slices).map: { ($_, $_.succ).map(* * $range-size + $min-ts).list }
}

sub get-bus-offsets {
    (^@buses)
            .map({ @buses[$_] => (@buses[$_] - $_) % @buses[$_] })
            .grep: *.key > 1;
}

sub empty-hash-for(@bus-list) {
    @bus-list.grep(* > 1).map: * => 0
}

sub increase-steps(%offsets, %scores, $step, $last-step = Inf) {
    my $steps;
    repeat while %scores !eqv %offsets && $steps < $last-step {
        $steps++;
        %scores{$_} = (%scores{$_} + $step) % $_ for %scores.keys;
    }
    $steps
}

sub calculate-min-block {
    my @biggest-buses = @buses.sort[* - 3 .. *];

    my %big-offsets = get-bus-offsets.grep({ .key == any @biggest-buses });
    my %big-scores = empty-hash-for @biggest-buses;

    my $ts-offset = increase-steps %big-offsets, %big-scores, 1;
    my $ts-block = increase-steps %big-offsets, %big-scores, 1;

    $ts-offset, $ts-block
}

sub calculate-range($range) {
    my %offsets = get-bus-offsets;
    my %scores = empty-hash-for @buses;

    # Increase steps and scores (by block size) to match begin of range
    my $steps = $range.head div $ts-block;
    %scores{$_} = ($ts-block * $steps) % $_ for %scores.keys;

    # Now add the initial offset of the block so that we align the data to the
    # biggest buses block so we can increase the steps with big-buses block
    %scores{$_} = (%scores{$_} + $ts-offset) % $_ for %scores.keys;

    # Increase by big-buses block and check if the result is correct
    my $last-step := 1 + ($range.tail + $ts-offset) div $ts-block;
    $steps += increase-steps %offsets, %scores, $ts-block, $last-step;

    # Translate steps value to timestamp.
    # Return 0 if we could not find a match in the range
    my $timestamp := $steps * $ts-block + $ts-offset;
    $timestamp > $range.tail ?? 0 !! $timestamp
}
