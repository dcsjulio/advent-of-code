#!/usr/bin/env raku

my @LINES = 'input'.IO.lines;

my $LENGTH := @LINES.head.chars;

sub get-column($line, $column) {
    ($line ~~ m:g/ :r ^^ . ** { $column } <(.)> /)
}

sub count-data(@lines, $c) {
    my $ones = @lines.map({ get-column $_, $c }).grep(* eq '1').elems;
    my $zeros = @lines.elems - $ones;
    $ones, $zeros
}

sub count-power-consumption {
    my $word = '';
    for ^$LENGTH -> $c {
        my ($ones, $zeros) = count-data(@LINES, $c);
        $word ~= $ones > $zeros ?? '1' !! '0';
    }

    my $high-number = $word.parse-base: 2;
    my $low-number = $word.trans('01' => '10').parse-base: 2;

    $high-number * $low-number
}

say 'Solution 1: ' ~ count-power-consumption;

sub count-element(:$is-oxygen) {
    my ($winner-a, $winner-b) = $is-oxygen ?? (1, 0) !! (0, 1);

    my @current-input = @LINES;
    for ^$LENGTH -> $c {
        my ($ones, $zeros) = count-data @current-input, $c;
        my $winner = $ones >= $zeros ?? $winner-a !! $winner-b;
        @current-input = @current-input.grep: { $winner eq get-column $_, $c };
        last if @current-input.elems == 1;
    }
    @current-input.head.parse-base: 2
}

say 'Solution 2: ' ~ count-element(:is-oxygen) * count-element(:!is-oxygen);