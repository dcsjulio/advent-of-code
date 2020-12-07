#! /usr/bin/raku

unit sub MAIN(UInt $method where 1 <= * <= 2);

my $sled-rental = rx:r/ :my $w;
    ^ (\d+) '-' (\d+) ' ' (\w) {$w=$2} ': '
    [.*? $2]**{$0..$1} [<!before $w>.]* $
/;

my $toboggan = rx:r/ :my $l;
    ^ (\d+) '-' (\d+) ' ' (\w) ': ' {$l=$2}
    [ .**{$0 - 1} $2 .**{$1 - $0 - 1} <!before $l>.
    | .**{$0 - 1} <!before $l>. .**{$1 - $0 - 1} $2 ]
/;

say 'input'.IO.lines.grep(*.match: $method == 1 ?? $sled-rental !! $toboggan).elems;
