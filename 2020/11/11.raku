#!/usr/bin/env raku

class Box {
    constant OCCUPIED = '#';
    constant FREE = 'L';
    constant NO-SEAT = '.';

    has $.value is rw;
    has $.switchable is rw = False;
    has $.max-occupied;

    method no-seat {
        $.value eq NO-SEAT
    }

    method occupied {
        $.value eq OCCUPIED
    }

    method free {
        $.value eq FREE
    }

    method will-switch($adjacent) returns Bool {
        $.switchable = self.occupied && $adjacent >= $.max-occupied
                    || self.free && $adjacent == 0
    }

    method switch {
        $.value = self.occupied ?? FREE !! OCCUPIED;
        $.switchable = False;
    }
}

class Board {
    has @!data;
    has $.can-change is rw = True;
    has $.new-method;

    submethod BUILD(:@input, :$new-method) {
        my @lines = @input.map(*.comb).map({ '|', |$_, '|' });
        my @bar = '+', |('-' xx @lines.elems), '+';
        my @data = @bar, |@lines, @bar;

        $!new-method = $new-method;

        @!data = @data>>.map: { Box.new: value => $_, max-occupied => $new-method ?? 5 !! 4 };
    }

    multi method get-box($y, $x) {
        @!data[$y;$x]
    }

    multi method get-box(@pointer) {
        @!data[@pointer.head;@pointer.tail]
    }

    method !can't-hold(@pointer) {
           @pointer.head ~~ 0 | @!data.elems.pred
        || @pointer.tail ~~ 0 | @!data.head.elems.pred
    }

    method !see-occupied($y, $x) {
        state @offsets = (-1, -1), (-1, 0), (-1, 1), (0, -1), (0, 1), (1, -1), (1, 0), (1, 1);
        my $occupied = 0;
        for @offsets -> @offset {
            my @pointer = $y, $x;
            repeat while $!new-method {
                @pointer = @pointer Z+ @offset;

                last if self!can't-hold: @pointer;
                next if $!new-method && self.get-box(@pointer).no-seat;

                $occupied++ if self.get-box(@pointer).occupied;
                last;
            }
        }
        $occupied;
    }

    method !get-boxes {
       @!data[1 .. * - 2].map({ $_[1 .. * - 2] }).flat
    }

    method update {
        $.can-change = False;
        for 1 .. @!data.elems - 2 -> $y {
            for 1 .. @!data.head.elems - 2 -> $x {
                my $occupied := self!see-occupied: $y, $x;
                $.can-change = True if self.get-box($y, $x).will-switch: $occupied;
            }
        }

        .switch if .switchable for self!get-boxes;
    }

    method count-occupied {
        elems self!get-boxes.grep(*.occupied)
    }
}

my $board;

## CASE 1 ##

$board = Board.new: input => 'input'.IO.lines, :!new-method;

$board.update while $board.can-change;

say 'CASE 1: ' ~ $board.count-occupied;

## CASE 2 ##

$board = Board.new: input => 'input'.IO.lines, :new-method;

$board.update while $board.can-change;

say 'CASE 2: ' ~ $board.count-occupied;
