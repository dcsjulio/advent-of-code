#!/usr/bin/env raku

my $input := 'input'.IO.slurp;

sub calculate($input, $depth-func, $final-depth) {
    ($input ~~ m:r/
    ^ :my ($f, $d, $aim) = 0, 0, 0;
    [   'forward ' (\d+) { $f += $0.tail; $d = $depth-func($d, $aim, $0.tail) }
    |   'up '      (\d+) { $aim -= $0.tail                                    }
    |   'down '    (\d+) { $aim += $0.tail                                    }
    ]+ % \n \n  $        { make $f * $final-depth($d, $aim)                   }
    /).made
}

say 'Solution 1: ' ~ calculate($input,
        -> $d, $a, $v { $d },
        -> $d, $a { $a });

say 'Solution 2: ' ~ calculate($input,
        -> $d, $a, $v { $d + $v * $a },
        -> $d, $a { $d });
