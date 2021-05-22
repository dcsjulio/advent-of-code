#!/usr/bin/env raku

class Cell {
    has $.y;
    has $.x;
    has $.flipped = False;
    has $.to-be-flipped is rw = False;

    method id {
        $!y ~ '_' ~ $!x
    }

    method starting-cell { Cell.new: y => 0, x => 0 }
    method east          { Cell.new: :$!y, x => $!x.succ }
    method west          { Cell.new: :$!y, x => $!x.pred }
    method north-east    { Cell.new: y => $!y.pred, x => $!x + $!y % 2 }
    method south-east    { Cell.new: y => $!y.succ, x => $!x + $!y % 2 }
    method north-west    { Cell.new: y => $!y.pred, x => $!x - $!y %% 2 }
    method south-west    { Cell.new: y => $!y.succ, x => $!x - $!y %% 2 }

    method neighbour-list {
        self.east,       self.west,
        self.north-east, self.north-west,
        self.south-east, self.south-west,
    }

    method advance($step) {
        given $step {
            when 'e' { self.east }
            when 'w' { self.west }
            when 'ne' { self.north-east }
            when 'nw' { self.north-west }
            when 'se' { self.south-east }
            when 'sw' { self.south-west }
        }
    }

    method travel($path) {
        my $cell = self;
        for $path.split: /se||sw||nw||ne||e||w/, :skip-empty, :v -> $step {
            $cell = $cell.advance: $step
        }
        $cell
    }

    method flip {
        $!flipped = !$!flipped
    }

    method flip-if {
        self.flip if $!to-be-flipped
    }
}

class Floor {
    has @.commands;
    has %!cells;
    has %!inspected;

    method flip-all {
        for @!commands -> $line {
            my $end-cell = Cell.starting-cell.travel: $line;
            my $cell = self.get-cell-or-keep: $end-cell;
            $cell.flip;
            %!cells{$cell.id} = $cell
        }
    }

    method get-cell-or-keep($cell) {
        %!cells{$cell.id}:exists ?? %!cells{$cell.id} !! $cell
    }

    method count-flipped {
        self.get-flipped.elems
    }

    method get-flipped {
        self.get-cells.grep: *.flipped
    }

    method get-cells {
        %!cells.values>>.values.flat
    }

    method delete-white {
        %!cells{.id}:delete for self.get-cells.grep: !*.flipped
    }

    method pass-one-day {
        %!inspected = ();
        for self.get-flipped -> $cell {
            self.mark-flipness: $_ for self.get-neighbours: $cell;
            self.mark-flipness: $cell;
        }
        self.flip-flippable;
        self.delete-white;
    }

    method mark-flipness($cell) {
        return if %!inspected{$cell.id};
        %!inspected{$cell.id} = True;

        my $black-count = self.count-black-neighbours: $cell;
        if $cell.flipped && $black-count != 1 | 2 {
            $cell.to-be-flipped = True;
        }
        elsif !$cell.flipped && $black-count == 2 {
            $cell.to-be-flipped = True;
            %!cells{$cell.id} = $cell
        }
    }

    method count-black-neighbours($cell) {
        elems self.get-neighbours($cell).grep: *.flipped
    }

    method get-neighbours($cell) {
        $cell.neighbour-list.map: { self.get-cell-or-keep: $_ }
    }

    method flip-flippable {
        for self.get-cells.grep: *.to-be-flipped -> $cell {
            $cell.flip;
            $cell.to-be-flipped = False;
        }
    }
}

my $floor = Floor.new: commands => 'input'.IO.lines;

$floor.flip-all;
say 'Case 1: ' ~ $floor.count-flipped;

$floor.pass-one-day for ^100;
say 'Case 2: ' ~ $floor.count-flipped;
