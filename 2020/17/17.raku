#!/usr/bin/env raku

class Cube {
    has $.active;
    has $.neighbours is rw;
    has $.x;
    has $.y;
    has $.w;
    has $.z;
    has @!coordinates is List;

    method !coords-calculate($to-number) {
        (1 .. $to-number).map({
            sprintf('%04d', .base: 3).comb>>.Int.map({ $_ > 1 ?? -1 !! $_ }).list
        }).list
    }

    submethod BUILD(:$char, :$!x, :$!y, :$!w, :$!z, :$hyper) {
        $!active = $char eq '#';
        $!neighbours = 0;
        @!coordinates := self!coords-calculate: $hyper ?? 80 !! 26;
    }

    method switch-it {
        $!active = $!active && $!neighbours == 2|3 || $!neighbours == 3;
    }

    method get-neighbour-coords {
        @!coordinates.map({ eager $_ Z+ ($!z, $!w, $!y, $!x) }).list
    }
}

class Grid {
    has %!data;
    has $!hyper;

    submethod BUILD(:@lines, :$hyper) {
        my ($x, $y, $w, $z) = 0, 0, 0, 0;
        $!hyper = $hyper;
        for @lines -> $line {
            for $line.comb -> $char {
                %!data{$z}{$w}{$y}{$x} = Cube.new: :$char, :$x, :$y, :$w, :$z, :$!hyper;
                $x++;
            }
            $y++;
            $x = 0;
        }
    }

    method !get($coords) {
        my ($z, $w, $y, $x) := $coords.list;
        if %!data{$z}{$w}{$y}{$x}:!exists {
            %!data{$z}{$w}{$y}{$x} = Cube.new: char => '.', :$z, :$w, :$y, :$x, :$!hyper;
        }
        %!data{$z}{$w}{$y}{$x}
    }

    method !get-cubes {
        eager %!data.values.map(*.values.map(*.values.map: *.values)).flat
    }

    method do-cycle {
        for self!get-cubes { self!increase-neighbours: $^cube }

        for self!get-cubes { .switch-it }

        for self!get-cubes { .neighbours = 0 }
    }

    method !increase-neighbours($cube) {
        return unless $cube.active;
        my @neighbours = $cube.get-neighbour-coords.map({ self!get: $_ });
        for @neighbours { .neighbours++ }
    }

    method count-active {
        elems self!get-cubes.grep: *.active
    }
}

my $normal-grid = Grid.new: lines => 'input'.IO.lines, :!hyper;
$normal-grid.do-cycle for ^6;
say 'CASE 1: ' ~ $normal-grid.count-active;

my $hyper-grid = Grid.new: lines => 'input'.IO.lines, :hyper;
$hyper-grid.do-cycle for ^6;
say 'CASE 2: ' ~ $hyper-grid.count-active;
