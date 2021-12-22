#!/usr/bin/env raku

constant %SCORES     = ')' => 3, ']' => 57, '}' => 1197, '>' => 25137;
constant %FIX-SCORES = ')' => 1, ']' => 2,  '}' => 3,    '>' => 4;

grammar NavigationSubsystem {
    token  TOP          { <group>+                                           }
    token  group        { <parentheses> | <brackets> | <braces> | <chevrons> }
    token  parentheses  { '(' <wants(')')> ~ ')' <group>*  <closes>          }
    token  brackets     { '[' <wants(']')> ~ ']' <group>*  <closes>          }
    token  braces       { '{' <wants('}')> ~ '}' <group>*  <closes>          }
    token  chevrons     { '<' <wants('>')> ~ '>' <group>*  <closes>          }
    token  succ         { <?>                                                }
    method wants($what) { %*needs{self.pos.pred} = $what ; self.succ         }
    method closes       { %*needs{self.from}:delete      ; self.succ         }
    method FAILGOAL($_) { $*last-pos max= self.pos       ; callsame          }
}

multi sub MAIN(Bool :$tests where !*) {
    my $input = 'input'.IO.slurp;
    say 'Solution 1: ' ~ [+] get-scores $input;
    say 'Solution 2: ' ~ completion-points($input).sort[*/2];
}

sub get-scores($input) {
    eager $input.lines.map: &score
}

sub score($line) {
    my ($*last-pos, %*needs) = 0, {};
    NavigationSubsystem.parse: $line or $*last-pos == $line.chars
            ?? 0
            !! %SCORES{$line.substr: $*last-pos, 1}
}

sub completion-points($input) {
    $input.lines.grep({ 0 == score $_ }).map: &get-fix-score
}

sub get-fix-score($line) {
    my ($*last-pos, %*needs) = 0, {};
    NavigationSubsystem.parse: $line;
    [[&fix-score]] 0, |%*needs.sort(*.key.Int).reverse.map: *.value
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

    plan 17;

    my ($input, $test, $result, $*last-pos, %*needs);

    $test = 'Can parse simple input 1';
    $input = '()';
    $*last-pos = 0;
    ok NavigationSubsystem.parse($input), $test;

    $test = 'Can parse simple input 2';
    $input = '[]';
    $*last-pos = 0;
    ok NavigationSubsystem.parse($input), $test;

    $test = 'Can parse simple input 3';
    $input = '{}';
    $*last-pos = 0;
    ok NavigationSubsystem.parse($input), $test;

    $test = 'Can parse simple input 1';
    $input = '<>';
    $*last-pos = 0;
    ok NavigationSubsystem.parse($input), $test;

    $test = 'Can parse simple input - all sequential';
    $input = '()[]{}<>';
    $*last-pos = 0;
    ok NavigationSubsystem.parse($input), $test;

    $test = 'Can parse simple input - all nested';
    $input = '([{<>}])';
    $*last-pos = 0;
    ok NavigationSubsystem.parse($input), $test;

    $test = 'Can parse complex input';
    $input = '([{<>(<>)<>}()]){()()<<<>>()>}[[]]';
    $*last-pos = 0;
    ok NavigationSubsystem.parse($input), $test;

    $test = 'Detects broken input';
    $input = '(()(((((';
    $*last-pos = 0;
    nok NavigationSubsystem.parse($input), $test;

    $test = 'Detects not finished input';
    $input = '(()(((((';
    $result = 0;
    is score($input), $result, $test;

    $test = 'Scores bad input';
    $input = '(()({)}';
    $result = 3;
    is score($input), $result, $test;

    $test = 'Scores bad input';
    $input = '(()({]}';
    $result = 57;
    is score($input), $result, $test;

    $test = 'Scores bad input';
    $input = '(()(<}}';
    $result = 1197;
    is score($input), $result, $test;

    $test = 'Scores bad input';
    $input = '(()({>}';
    $result = 25137;
    is score($input), $result, $test;

    $test = 'Can calculate fixed score from fixing string';
    $input = '])}>';
    $result = 294;
    is ([[&fix-score]] 0, |$input.comb), $result, $test;

    $test = 'Can calculate fixed score from fixing string - high';
    $input = '}}>}>))))';
    $result = 1480781;
    is ([[&fix-score]] 0, |$input.comb), $result, $test;

    $test = 'Can calculate fixed score from fixing string - not as high';
    $input = ']]}}]}]}>';
    $result = 995444;
    is ([[&fix-score]] 0, |$input.comb), $result, $test;

    $test = 'Can calculate fixed score from input string';
    $input = '[(()[<>])]({[<{<<[]>>(';
    $result = 5566;
    is get-fix-score($input), $result, $test;
}