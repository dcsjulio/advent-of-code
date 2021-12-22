#!/usr/bin/env raku

constant %SCORES     = ')' => 3, ']' => 57, '}' => 1197, '>' => 25137;
constant %FIX-SCORES = ')' => 1, ']' => 2,  '}' => 3,    '>' => 4;

multi sub MAIN(Bool :$tests where !*) {
    my $input = 'input'.IO.slurp;
    say 'Solution 1: ' ~ [+] $input.lines.map: &wrong-points;
    say 'Solution 2: ' ~ completion-points($input).sort[*/2];
}

sub clean($line) {
    my $replaced = $line;
    while $replaced ~~ s:g/['<>'|'[]'|'{}'|'()']+:// {}
    $replaced
}

sub wrong-points($line) {
    clean($line).match: /<[>})\]]>/ andthen %SCORES{$_} orelse 0
}

sub completion-points($input) {
    $input.lines.grep({ 0 == wrong-points $_ }).map: &get-fix-score
}

sub get-fix-score($line) {
    [[&fix-score]] 0, |clean($line).flip.trans('([{<' => ')]}>').comb
}

sub fix-score($score, $char) {
    $score * 5 + %FIX-SCORES{$char}
}

#################################################
##################### TESTS #####################
#################################################

multi sub MAIN(Bool :$tests where *) {
    use Test;

    say "Running day10 tests...";

    plan 7;

    my ($input, $test, $result, $*last-pos, %*needs);

    $test = 'Can clean nested structures';
    $input = '()()(({{}}))[<>]<>';
    $result = '';
    is clean($input), $result, $test;

    $test = 'Can get 0 points on good string';
    $input = '<><>';
    $result = 0;
    is wrong-points($input), $result, $test;

    $test = 'Can get 0 points on incomplete string';
    $input = '<>((';
    $result = 0;
    is wrong-points($input), $result, $test;

    $test = 'Can clean nested structures and get points';
    $input = '{{()()(({{(}}))[<>]<>{{';
    $result = 1197;
    is wrong-points($input), $result, $test;

    $test = 'Can get fixing score - string1';
    $input = '[({(<(())[]>[[{[]{<()<>>';
    $result = 288957;
    is get-fix-score($input), $result, $test;

    $test = 'Can get fixing score - string2';
    $input = '[(()[<>])]({[<{<<[]>>(';
    $result = 5566;
    is get-fix-score($input), $result, $test;

    $test = 'Can get fixing score - string3';
    $input = '(((({<>}<{<{<>}{[]{[]{}';
    $result = 1480781;
    is get-fix-score($input), $result, $test;
}