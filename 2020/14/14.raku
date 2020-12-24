#! /usr/bin/env raku

my $data = 'input'.IO.slurp;

my $mask;
my &set-ones  = { +$_ +| $mask.trans('X' => '0').parse-base: 2 }

## CASE 1 ##

my &set-zeros = { +$_ +& $mask.trans('X' => '1').parse-base: 2 }
my %values-c1 is default(0);

$data ~~ m:g/
      'mask = '(<[01X]>+)    { $mask = ~$0 }
    | 'mem['(\d+)'] = '(\d+) { %values-c1{~$0} = set-zeros set-ones ~$1 }
/;

say "CASE 1: {%values-c1.values.sum}";

## CASE 2 ##

my %values-c2 is default(0);

$data ~~ m:g/
      'mask = '(<[01X]>+)    { $mask = ~$0 }
    | 'mem['(\d+)'] = '(\d+) { %values-c2{$_} = +$1 for get-addresses set-ones +$0 }
/;

say "CASE 2: {%values-c2.values.sum}";

sub to-base2($x, $max = 36) {
    "{'0' x $max}{$x.base: 2}".substr: * - $max
}

sub get-addresses($memory) {
    my @mem-bits = to-base2($memory).comb;
    my @float-pos = ($mask.comb Z ^$mask.chars).grep(*.head eq 'X').map: *.tail;
    my @combinations = (^2 ** @float-pos.elems).map({ to-base2 $_, @float-pos.elems }).map: *.comb;

    @combinations.map({ @mem-bits[@float-pos] = .list; @mem-bits.join.parse-base(2) })
}


