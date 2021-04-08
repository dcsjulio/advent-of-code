#!/usr/bin/env raku

my @lines := 'input'.IO.lines.list;

grammar Calculator {
    token TOP              { ^ ')' <calc-op> '(' $ | <calc-op> }

    proto rule calc-op     { * }
    rule calc-op:sum<one>  { <num> '+' <num> <.no-op> }
    rule calc-op:sum<more> { <num> '+' <calc-op> }
    rule calc-op:mul<one>  { <num> '*' <num> <.no-op> }
    rule calc-op:mul<more> { <num> '*' <calc-op> }

    proto rule num         { * }
    rule num:num<real>     { \d+ }
    rule num:num<pars>     { ')' <calc-op> '(' }

    regex no-op            { <!before <[+*]>> }
}

class Calculations {
    method TOP               ($/) { make $<calc-op>.made }
    method calc-op:sum<one>  ($/) { make [+] $<num>>>.made }
    method calc-op:sum<more> ($/) { make [+] $<num>.made, $<calc-op>.made }
    method calc-op:mul<one>  ($/) { make [*] $<num>>>.made }
    method calc-op:mul<more> ($/) { make [*] $<num>.made, $<calc-op>.made }
    method num:num<real>     ($/) { make +$/.trim.flip }
    method num:num<pars>     ($/) { make +$<calc-op>.made }
}

say 'Case 1: ' ~ [+] @lines.map: { Calculator.parse(.flip, actions => Calculations).made };
