#!/usr/bin/env raku

sub parse-balls {
    'input'.IO.lines.head.split(',').map: &zpad
}

sub parse-input {
    zpad 'input'.IO.slurp.subst(/^.*?\n\n/, '').subst: /<after \d>\n/, ' ', :g
}

sub zpad($number) {
    $number.subst: / <(' ')> \d <wb> | <(^)> \d $ /, '0', :g
}

sub mark-number($ball, $input) {
    $input.subst: $ball, 'XX', :g
}

sub get-winner($input) {
    $input.match: /
    ^^ [ [ <-[\n]>**15 ]*  'XX XX XX XX XX' <-[\n]>*
       | [ [<-[\n]>**3]**0 'XX ' [<-[\n]>**3]**4 ]**5
       | [ [<-[\n]>**3]**1 'XX ' [<-[\n]>**3]**3 ]**5
       | [ [<-[\n]>**3]**2 'XX ' [<-[\n]>**3]**2 ]**5
       | [ [<-[\n]>**3]**3 'XX ' [<-[\n]>**3]**1 ]**5
       | [ [<-[\n]>**3]**4 'XX ' [<-[\n]>**3]**0 ]**5 ]
    $$/
}

sub count-numbers($line) {
    $line.split(/\s/).grep({ /\d/ })>>.Int.sum
}

sub remove-winner($input, $winner) {
    $input.subst: / ^^ $winner [\n|$] /, ''
}

my @BALLS = parse-balls;

my ($found, $last-ball, $input, $last-input);

$input = parse-input;

for @BALLS -> $ball {
    $input = mark-number $ball, $input;
    $last-ball = $ball;
    last if $found = get-winner $input;
}

say 'Solution 1: ' ~ count-numbers($found) * $last-ball;

$input = parse-input;

for @BALLS -> $ball {
    $input = mark-number $ball, $input;
    $last-ball = $ball;

    while $found = get-winner $input {
        $last-input = $input;
        $input = remove-winner $input, $found;
    }

    last if $input eq '';
}

say 'Solution 2: ' ~ count-numbers($last-input) * $last-ball;
