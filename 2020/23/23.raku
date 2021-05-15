#!/usr/bin/env raku

class Board {
    has %.cups;
    has $.removed;
    has $.first;
    has $.destination;
    has $!max-numbers;

    submethod BUILD(:$input, :$!max-numbers = 9) {
        my @numbers = $input.comb.list;
        if $!max-numbers > 9 {
            @numbers = |@numbers, |(10 .. $!max-numbers)>>.Str;
        }
        %!cups = @numbers.rotor(2 => -1).map: { .head => .tail };
        %!cups{@numbers.tail} = @numbers.head;
        $!first = @numbers.head;
    }

    method make-step {
        self!remove-elements;
        self!update-destination;
        self!insert-removed;
        self!advance-current;
    }

    method result1 {
        my $result = '';
        my $next = '1';
        for ^8 {
            $result ~= %!cups{$next};
            $next = %!cups{$next};
        }
        $result;
    }

    method result2 {
        %!cups{'1'} * %!cups{%!cups{'1'}};
    }

    method !remove-elements {
        $!removed = %!cups{$!first};
        %!cups{$!first} = %!cups{%!cups{%!cups{%!cups{$!first}}}};
    }

    method !advance-current {
        $!first = %!cups{$!first};
    }

    method !removed {
        $!removed, %!cups{$!removed}, %!cups{%!cups{$!removed}};
    }

    method !update-destination {
        my $new = $!first.Int;
        loop {
            $new--;
            $new = $!max-numbers if $new < 1;
            last if $new.Str ∉ self!removed;
        }
        $!destination = $new.Str;
    }

    method !insert-removed {
        my $end = %!cups{$!destination};
        %!cups{$!destination} = $!removed;
        %!cups{%!cups{%!cups{$!removed}}} = $end;
    }
}

my $board1 = Board.new: input => '614752839';
$board1.make-step for ^100;
say 'Case 1: ' ~ $board1.result1;

my $board2 = Board.new: input => '614752839', max-numbers => 1_000_000;
$board2.make-step for ^10_000_000;
say 'Case 2: ' ~ $board2.result2;
