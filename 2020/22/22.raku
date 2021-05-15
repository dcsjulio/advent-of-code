#!/usr/bin/env raku

class DeckParser {
    has $.input;
    has @.deck-player1 is List;
    has @.deck-player2 is List;

    method BUILD(:$!input) {
        self!parse;
    }

    method !parse {
        my @cards;
        my $player = 0;
        for $!input ~~ m:g/^^\D\N+\n(\d+)+ % \n/ -> \match {
            @cards[$player++] := match[0]>>.Int.list
        }
        @!deck-player1 := @cards.head.list;
        @!deck-player2 := @cards.tail.list;
    }
}

role Playing {
    has @.deck1;
    has @.deck2;

    method play {
        self!change while not self!end-of-data;
    }

    method winner {
        @!deck2.elems == 0 ?? 1 !! 2
    }

    method score {
        my @cards := self.winner == 1 ?? @!deck1 !! @!deck2;
        [+] @cards.reverse Z* 1 .. @cards.elems
    }

    method !end-of-data {
        @!deck1.elems == 0 || @!deck2.elems == 0
    }

    method !change-simple(\one, \two, \force-winner = 0) {
        if force-winner == 1 || force-winner == 0 && one > two  {
            @!deck1.push: one;
            @!deck1.push: two;
        }
        elsif force-winner == 2 || force-winner == 0 && two > one {
            @!deck2.push: two;
            @!deck2.push: one;
        }
    }
}

class SimpleGame does Playing {
    method !change {
        self!change-simple: @!deck1.shift, @!deck2.shift;
    }
}

class RecursiveGame does Playing {
    has %.states is default(False);

    method !repeated-state {
        my \game-state = "{@!deck1.join: ','}❤{@!deck2.join: ','}";
        return True if %!states{game-state}:exists;
        %!states{game-state} = True;
        False
    }

    method !can-recurse(\one, \two) {
        one <= @!deck1.elems && two <= @!deck2.elems && one != 0 && two != 0
    }

    method !change {
        my \one = @!deck1.shift;
        my \two = @!deck2.shift;

        if self!repeated-state {
            @!deck2 = ();
        } elsif self!can-recurse: one, two {
            my \new-game = RecursiveGame.new:
                    deck1 => @!deck1[^one],
                    deck2 => @!deck2[^two];

            new-game.play;
            self!change-simple: one, two, new-game.winner;
        } else {
            self!change-simple: one, two;
        }
    }
}

my \parser = DeckParser.new:
        input => 'input'.IO.slurp;

my \game = SimpleGame.new:
        deck1 => parser.deck-player1,
        deck2 => parser.deck-player2;

game.play;
say 'Case 1: ' ~ game.score;

my \r-game = RecursiveGame.new:
        deck1 => parser.deck-player1,
        deck2 => parser.deck-player2;

r-game.play;
say 'Case 2: ' ~ r-game.score;
