#!/usr/bin/env raku

my @matches = 'input'.IO.slurp ~~ m:g/:r
    [ ('byr:') (\d+)     <?{ 1920 <= $1.tail <= 2002 }>
    | ('iyr:') (\d+)     <?{ 2010 <= $1.tail <= 2020 }>
    | ('eyr:') (\d+)     <?{ 2020 <= $1.tail <= 2030 }>
    | ('hgt:') (\d+)   [ <?{ 59   <= $1.tail <= 76   }> 'in'
                       | <?{ 150  <= $1.tail <= 193  }> 'cm' ]
    | ('hcl:') '#' <[a..f]+[0..9]> ** 6
    | ('ecl:') ['amb'|'blu'|'brn'|'gry'|'grn'|'hzl'|'oth']
    | ('pid:') \d ** 9
    | ('cid:') \S+
    ]+ % \s \n [ \n | $ ]
    { make $0.grep(* ne 'cid:').elems == 7 }
/;

say @matches.map(*.made).grep(so *).elems;
