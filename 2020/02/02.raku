#! /usr/bin/raku

my $sled-rental = rx:r/ :my $w;
    ^ (\d+) '-' (\d+) ' ' (\w) {$w=$2} ': '
    [.*? $2]**{$0..$1} [<!before $w>.]* $
/;

my $toboggan = rx:r/ :my $l;
    ^ (\d+) '-' (\d+) ' ' (\w) {$l=$2} ': '
    [ .**{$0 - 1} $2 .**{$1 - $0 - 1} <!before $l>.
    | .**{$0 - 1} <!before $l>. .**{$1 - $0 - 1} $2 ]
/;

say 'Sled rental bad passwords: ' ~ 'input'.IO.lines.grep($sled-rental).elems;

say 'Toboggan bad passwords: ' ~ 'input'.IO.lines.grep($toboggan).elems;
