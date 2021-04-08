#!/usr/bin/env raku

use MONKEY-SEE-NO-EVAL;

my @lines := 'input'.IO.lines.list;

sub infix:<🡄+> (\a, \b) is equiv(&[+]) { a + b }
sub infix:<🡄*> (\a, \b) is equiv(&[+]) { a * b }

say 'Case 1: ' ~ [+] @lines.map({ .subst: /<[*+]>/, {"🡄$/"}, :g }) .map({ EVAL $_ });

sub infix:<🔄+> (\a, \b) is equiv(&[*]) { a + b }
sub infix:<🔄*> (\a, \b) is equiv(&[+]) { a * b }

say 'Case 2: ' ~ [+] @lines.map({ .subst: /<[*+]>/, {"🔄$/"}, :g }).map({ EVAL $_ });
