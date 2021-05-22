#!/usr/bin/env raku

constant $public-key := 5249543;
constant $public-key-other := 14082811;
constant $module := 20201227;
constant $initial-subject := 7;

class EncriptionData { has ($.loop-size, $.subject) }

sub calculate-subject(:$to-find = -1, :$initial, :$limit = Inf) {
    my $subject = 1;
    my $loop-size = 0;
    for ^$limit {
        $subject = ($subject * $initial) % $module;
        $loop-size++;
        last if $subject == $to-find;
    }
    EncriptionData.new: :$loop-size, :$subject
}

my $finder := calculate-subject to-find => $public-key, initial => $initial-subject;
my $secret := calculate-subject initial => $public-key-other, limit => $finder.loop-size;

say 'Result: ' ~ $secret.subject;
