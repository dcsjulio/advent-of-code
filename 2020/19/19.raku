#!/usr/bin/env raku

use MONKEY-SEE-NO-EVAL;
use experimental :cached;

sub parse-rule($line) {
    $line ~~ m/^(\d+) ': ' (.+)/ or die 'Cannot parse rule';
    ~$0 => (~$1).subst('"', '\'', :g)
}

my @lines = 'input'.IO.lines;
my %rules = @lines.grep({ m/^\d/ }).map: &parse-rule;
my @data  = @lines.grep({ m/^<[ab]>/ });

my ($rule42, $rule31, $new-rule8, $new-rule11);

sub eval-rule($rule, $loops) is cached {
    $rule.subst(/\d+/, {
        if $loops && $/ eq '8' {
            $new-rule8
        } elsif $loops && $/ eq '11' {
            $new-rule11
        } else {
            '[' ~ eval-rule(%rules{$/}, $loops) ~ ']'
        }
    }, :g);
}

say 'Case 1: ' ~ elems @data.grep: { $^it ~~ / ^ <{ eval-rule '0', False }> $ / };

$rule42 = eval-rule %rules{42}, False;
$rule31 = eval-rule %rules{31}, False;

$new-rule8  = ' [ <$rule42> | <$rule42> .**0 ] ';
for ^3 { $new-rule8 = $new-rule8.subst: /'.**0'/, $new-rule8 }

$new-rule11 = ' [ <$rule42> <$rule31> | <$rule42> .**0 <$rule31> ] ';
for ^3 { $new-rule11 = $new-rule11.subst: /'.**0'/, $new-rule11 }

say 'Case 2: ' ~ elems @data.grep: { $^it ~~ / ^ <{ eval-rule '0', True }> $ / };
