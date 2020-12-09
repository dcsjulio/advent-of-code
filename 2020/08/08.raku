#!/usr/bin/env raku

subset OpType where * ~~ 'nop' | 'acc' | 'jmp';

class Instruction {
    has OpType $.type is rw;
    has Int $.value;
    has Bool $.seen is rw;

    submethod BUILD(:$line) {
        $line ~~ /(\w+) ' '  (<[-+]> \d+)/ or die "Error parsing $line";
        $!type = $0.Str;
        $!value = $1.Int;
        $!seen = False;
    }

    method can't-switch {
        $.type eq 'acc'
    }

    method switch {
        state %switch = 'nop' => 'jmp', 'jmp' => 'nop';
        $.type = %switch{$.type};
    }
}

class Program {
    has Instruction @!lines;
    has UInt $!pointer;
    has Int $.acc is rw;

    submethod BUILD(:@lines) {
        @!lines = @lines.map({ Instruction.new: line => $_ });
    }

    method get-instruction($pos) {
        @!lines[$pos]
    }

    method line-count {
        @!lines.elems
    }

    method ended {
        $!pointer == @!lines.elems
    }

    method safe-run {
        $!pointer = 0;
        $.acc = 0;

        .seen = False for @!lines;

        while !self.ended {
            my $instruction := @!lines[$!pointer];

            last if $instruction.seen;

            $instruction.seen = True;
            $.acc += $instruction.type eq 'acc' ?? $instruction.value !! 0;
            $!pointer += $instruction.type eq 'jmp' ?? $instruction.value !! 1;
        }
    }
}

my $program = Program.new: lines => 'input'.IO.lines;

## CASE 1: ##

$program.safe-run;
say 'Case 1 result: ' ~ $program.acc;

## CASE 2: ##

for ^$program.line-count -> $switching-pos {
    my $instruction := $program.get-instruction: $switching-pos;

    next if $instruction.can't-switch;

    $instruction.switch;
    $program.safe-run;
    $instruction.switch;

    last if $program.ended;
}

say 'Case 2 result: ' ~ $program.acc;
