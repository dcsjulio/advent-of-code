#! /usr/bin/env raku

my $input = 'input'.IO.slurp;
my @ranges;
my @tickets;
my @bad-tickets;
my @my-ticket;

## CASE 1 ##

sub invalid($number) {
    not +$number ~~ any @ranges.map({ slip $^it })
}

$input ~~ m:g/
     ^^ [<-[:]>+]': '(\d+)'-'(\d+)' or '(\d+)'-'(\d+)      { @ranges.push: ( +$0[0]..+$1, +$2..+$3 ) }
  || ^^ [ (\d+:) ','? ]+ \n \n                             { @my-ticket = $0>>.Int }
  || ^^ [ (\d+:) ','? ]+ $$ <?{ +$0.grep(&invalid) == 0 }> { @tickets.push: $0>>.Int }
  || ^^ [ (\d+:) ','? ]+ $$                                { @bad-tickets.push: $0>>.Int }
/;

say 'Case 1: ' ~ @bad-tickets>>.list.flat.grep(&invalid).sum;

## CASE 2 ##

sub valid-position($item) {
    (^@ranges).map({ $^i, $item ~~ any @ranges[$^i].list }).grep(*.tail).map: *.head
}

my @valid-indexes = @tickets.map: *.map(&valid-position);
my @sets = (^+@valid-indexes.head).map: { ([∩] @valid-indexes>>[$_]).SetHash };

my %seen;
while +@sets.grep(*.keys.elems > 1) > 0 {
    my $next = +@sets.grep(+*.keys == 1).map(*.keys.head).grep(* !== any %seen.keys).head;
    %seen{$next} = True;
    for @sets.grep(+*.keys > 1) { $^set.unset: $next }
}

my @indexes = @sets.map(*.keys.head).pairs.grep(*.value < 6).map(*.key);
say 'Case 2: ' ~ [*] @my-ticket[@indexes];
