#! /usr/bin/raku

unit sub MAIN(UInt $numbers-to-add where * > 1);

say [*] 'input'.IO.lines
        .combinations($numbers-to-add)
        .grep({ 2020 == [+] @^them })
        .flat;