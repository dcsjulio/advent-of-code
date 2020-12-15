#!/usr/bin/env raku

my $input = 'input'.IO.slurp;

my @steps is List = (0, 1), (-1, 0), (0, -1), (1, 0);
my %index = E => 0, S => 1, W => 2, N => 3;
my @current;

## CASE 1 ##

my $rotator = 0;
@current = 0, 0;

$input ~~ m:g/:r
    [ (<[NSEW]>) (\d+) { @current = @current Z+ @steps[%index{$0}] for ^$1 }
    | R (\d+)          { $rotator = ($rotator + ($0/90)) % 4 }
    | L (\d+)          { $rotator = ($rotator - ($0/90)) % 4 }
    | F (\d+)          { @current = @current Z+ @steps[$rotator].list for ^$0 }
    ] /;

say 'CASE 1: ' ~ @current>>.abs.sum;

## CASE 2 ##

my @waypoint = 1, 10;
@current = 0, 0;

$input ~~ m:g/:r
    [ (<[NSEW]>) (\d+) { @waypoint = @waypoint Z+ @steps[%index{$0}] for ^$1 }
    | R (\d+)          { @waypoint = -@waypoint.tail, @waypoint.head for ^($0/90) }
    | L (\d+)          { @waypoint = @waypoint.tail, -@waypoint.head for ^($0/90) }
    | F (\d+)          { @current  = @current Z+ @waypoint for ^$0 }
    ] /;

say 'CASE 2: ' ~ @current>>.abs.sum;

