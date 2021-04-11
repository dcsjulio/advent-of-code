#!/usr/bin/env raku

role Flippable {
    has @.inner-data;
    has $.number-flips is rw = 0;

    method print-it {
        for @!inner-data { .say }
    }

    method !flip-it {
        given ++$!number-flips {
            when 1     { self!flip-x }
            when 2|4|7 { self!flip-y }
            when 3     { self!rotate90 }
            when 5|6   { self!rotate90 for ^3 }
        }
    }

    method !rotate90 {
        @!inner-data = (^@!inner-data.elems).map(-> $i {
            @!inner-data.map({ .comb[$i] }).reverse.join
        })
    }

    method !flip-x {
        @!inner-data .= reverse
    }

    method !flip-y {
        @!inner-data .= map: *.flip
    }
}

class Tile does Flippable {
    has ($.top, $.right, $.bottom, $.left, $.id, $.state);

    submethod BUILD(:$input) {
        my @data := $input.lines[1..*].list;

        $!id = +~($input ~~ m/Tile \h+ <(\d+)>/);

        ($!top, $!right, $!bottom, $!left) =
                @data[0], @data.map({.substr: *-1, 1}).join,
                @data[*-1], @data.map({.substr: 0, 1}).join;

        @!inner-data = @data[1 .. *-2].map: *.subst: /^.|.$/, :g;

        $!state = 0
    }

    method flip-x-borders {
        state @conversion = 1, 0, 5, 6, 7, 2, 3, 4;
        $!state = @conversion[$!state];
        ($!top, $!right, $!bottom, $!left) = $!bottom, $!right.flip, $!top, $!left.flip
    }

    method flip-y-borders {
        state @conversion = 5, 2, 1, 4, 3, 0, 7, 6;
        $!state = @conversion[$!state];
        ($!top, $!right, $!bottom, $!left) = $!top.flip, $!left, $!bottom.flip, $!right
    }

    method rotate90-borders {
        state @conversion = 7, 6, 3, 0, 1, 4, 5, 2;
        $!state = @conversion[$!state];
        ($!top, $!right, $!bottom, $!left) = $!left.flip, $!top, $!right.flip, $!bottom
    }

    method rotate180-borders {
        state @conversion = 3, 4, 7, 2, 5, 6, 1, 0;
        $!state = @conversion[$!state];
        ($!top, $!right, $!bottom, $!left) = $!right, $!bottom.flip, $!left, $!top.flip
    }

    method flip-borders {
        given ++$!number-flips {
            when 1     { self.flip-x-borders }
            when 2|4|7 { self.flip-y-borders }
            when 3     { self.rotate90-borders }
            when 5|6   { self.rotate180-borders }
            default    { die 'Unexpected number of flips' }
        }
    }

    method no-more-flips {
        $!number-flips >= 7
    }

    method flip-to-state {
        $!number-flips = 0;
        for 1 .. $!state { self!flip-it }
    }
}

class SensorGroup {
    has ($.side, $!index, $!flip-root);
    has (@!tiles, @!tested-units is default(0), @!used-ids, @!tile-map);

    submethod BUILD(:$data) {
        my @str-tiles = $data.split(/\n <before 'Tile'>/).list;
        $!side = @str-tiles.elems.sqrt.Int;
        for @str-tiles { @!tiles.push: Tile.new: :$^input }
        $!index = 0
    }

    method arrange {
        self!make-guess while $!index < $!side ** 2;
        self!flip-whole-data
    }

    method get-corners {
        @!tile-map.head.id, @!tile-map[$!side - 1].id,
        @!tile-map[$!side * $!side - $!side].id, @!tile-map.tail.id
    }

    method get-whole-data {
        @!tile-map
                .map(*.inner-data)
                .rotor($!side)
                .map({ ([Z] $_).map: *.join })
                .flat
    }

    method !make-guess {
        if !defined self!current-tile {
            self!add-next-tile;
        } elsif !$!flip-root && self!valid-tile {
            $!index++;
        } elsif self!current-tile.no-more-flips {
            if self!all-tiles-tested {
                $!flip-root = True;
                self!reset-current-tested-counter;
            }
            self!remove-last-tile;
            if $!index > 0 {
                $!index--;
            }
        } else {
            self!current-tile.flip-borders;
            $!flip-root = False;
        }
    }

    method !all-tiles-tested {
        @!tested-units[$!index] == $!side * $!side - $!index
    }

    method !get-next-tile {
        @!tiles.grep(*.id ∉ @!used-ids)[@!tested-units[$!index] - 1]
    }

    method !reset-current-tested-counter {
        @!tested-units[$!index] = 0
    }

    method !current-tile is rw {
        @!tile-map[$!index]
    }

    method !remove-last-tile {
        @!tile-map[$!index].number-flips = 0;
        pop @!tile-map;
        pop @!used-ids
    }

    method !add-next-tile {
        @!tested-units[$!index]++;
        @!tile-map[$!index] = self!get-next-tile;
        @!used-ids.push: @!tile-map[$!index].id
    }

    method !valid-tile {
        my ($y, $x) := $!index div $!side, $!index % $!side;
        my $ok-left = $x == 0 || @!tile-map[$!index].left eq @!tile-map[$!index - 1].right;
        my $ok-top = $y == 0 || @!tile-map[$!index].top eq @!tile-map[$!index - $!side].bottom;
        $ok-left && $ok-top
    }

    method !flip-whole-data {
        for @!tile-map { .flip-to-state }
    }
}

class MonsterMap does Flippable {
    has $.number-of-monsters = 0;

    method find-monsters {
        for ^8 {
            self!mark-monsters;
            last if $!number-of-monsters > 0;
            self!flip-it;
        }
    }

    method water-roughness {
        @!inner-data.map({ elems m:g/'#'/ }).sum
    }

    method !mark-monsters {
        my $count = 0;
        my $data = @!inner-data.join: "\n";
        while $data ~~ s:g/ :my $len = 0;
        ^^(\N*?)        (\N**18)'#'(.) (\N*\n) { $len = (~$0).chars.Int }
        ^^(\N**:{$len}) '#'(....)'##'(....)'##'(....)'###' (\N*\n)
        ^^(\N**:{$len}) (.)'#'(..)'#'(..)'#'(..)'#'(..)'#'(..)'#'(...) { $count++ }
        /$0$1O$2$3$4O$5OO$6OO$7OOO$8$9$10O$11O$12O$13O$14O$15O$16/ {};
        $!number-of-monsters += $count;
        @!inner-data = $data.split: "\n"
    }
}

my $sensor-group = SensorGroup.new: data => 'input'.IO.slurp;
$sensor-group.arrange;
say 'CASE 1: ' ~ [*] $sensor-group.get-corners;

my $monster-map = MonsterMap.new: inner-data => $sensor-group.get-whole-data;
$monster-map.find-monsters;
$monster-map.print-it;
say 'CASE 2: ';
say '     Water Roughness: ' ~ $monster-map.water-roughness;
say '  Number of monsters: ' ~ $monster-map.number-of-monsters;
