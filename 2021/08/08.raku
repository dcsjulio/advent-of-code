#!/usr/bin/env raku

enum SEGMENT_DIGITS <abcefg cf acdeg acdfg bcdf abdfg abdefg acf abcdefg abcdfg>;

multi sub MAIN(Bool :$tests where !*) {
    my $input = 'input'.IO.slurp;
    say 'Solution 1: ' ~ count-simple $input;
    say 'Solution 2: ' ~ solve-and-add $input;
}

sub count-simple($input) {
    elems get-guesses-and-digits($input)
            .map(*.value)
            .flat
            .grep: *.chars ⊂ (2, 3, 4, 7)
}

sub solve-and-add($input) {
    [+] get-guesses-and-digits($input).map: &get-real-numbers
}

sub get-guesses-and-digits($input) {
    $input.lines.map: { Pair.new: | .split(' | ').map(*.words.list) }
}

sub get-real-numbers($line-data) {
    $line-data.value.words
            .map(*.trans: get-trans-string($line-data) => 'abcdefg')
            .map(*.comb.sort.join)
            .map({ SEGMENT_DIGITS.enums.grep: *.key eq $^it })
            .map(*.head.value)
            .join.Int
}

sub get-trans-string($line-data) {
    my %by-length = get-common-by-length $line-data;

    my $a = ~[∩] %by-length<3 5 6>;
    my $f = ~[∩] %by-length<2 3 4 6>;
    my $d = ~[∩] %by-length<4 5>;
    my $b = ~(([∩] %by-length<4 6>) ∖ $f);
    my $c = ~(([∩] %by-length<2 3 4>) ∖ $f);
    my $g = ~(([∩] %by-length<5 6>) ∖ $a);
    my $e = ~(%by-length<7> ∖ [∪] $a, $b, $c, $d, $f, $g);

    "$a$b$c$d$e$f$g"
}

sub get-common-by-length($line-data) {
    my %by-length is default(Set.new('abcdefg'.comb));
    for $line-data.key.words {
        %by-length{.chars} ∩= .comb;
    }
    %by-length
}

#################################################
##################### TESTS #####################
#################################################

multi sub MAIN(Bool :$tests where *) {
    use Test;

    say "Running day08 tests...";

    plan 7;

    my ($input, $test, $result, %result);

    $test = 'Can split input data';
    $input = 'foo bar | baz baz';
    $result = (('foo', 'bar') => ('baz', 'baz'),);
    is-deeply get-guesses-and-digits($input), $result, $test;

    $test = 'Can split input data, several lines';
    $input = "foo1 bar1 | baz1 baz1\nfoo2 bar2 | baz2 baz2";
    $result = List.new:
            ('foo1', 'bar1') => ('baz1', 'baz1'),
            ('foo2', 'bar2') => ('baz2', 'baz2');
    is-deeply get-guesses-and-digits($input), $result, $test;

    $test = 'Can solve dummy test';
    $input = 'foo | 1 22 333 4444 55555 666666 7777777 88888888 999999999';
    $result = 4;
    is count-simple($input), $result, $test;

    $test = 'Can solve first example';
    $input = q:to/END/;
    be cfbegad cbdgef fgaecd cgeb fdcge agebfd fecdb fabcd edb | fdgacbe cefdb cefbgd gcbe
    edbfga begcd cbg gc gcadebf fbgde acbgfd abcde gfcbed gfec | fcgedb cgb dgebacf gc
    fgaebd cg bdaec gdafb agbcfd gdcbef bgcad gfac gcb cdgabef | cg cg fdcagb cbg
    fbegcd cbd adcefb dageb afcb bc aefdc ecdab fgdeca fcdbega | efabcd cedba gadfec cb
    aecbfdg fbg gf bafeg dbefa fcge gcbea fcaegb dgceab fcbdga | gecf egdcabf bgf bfgea
    fgeab ca afcebg bdacfeg cfaedg gcfdb baec bfadeg bafgc acf | gebdcfa ecba ca fadegcb
    dbcfg fgd bdegcaf fgec aegbdf ecdfab fbedc dacgb gdcebf gf | cefg dcbef fcge gbcadfe
    bdfegc cbegaf gecbf dfcage bdacg ed bedf ced adcbefg gebcd | ed bcgafe cdgba cbgef
    egadfb cdbfeg cegd fecab cgb gbdefca cg fgcdab egfdb bfceg | gbdfcae bgc cg cgb
    gcafb gcf dcaebfg ecagb gf abcdeg gaef cafbge fdbac fegbdc | fgae cfgab fg bagce
    END
    $result = 26;
    is count-simple($input), $result, $test;

    $test = 'Can get classify common segments by length';
    $input = 'abdfce bedag acdefgb cg febcga fbdac fcdg cabdg bcg bgacdf | fdcab adbcf gcb acdebf';
    $input = get-guesses-and-digits($input).head;
    %result =
            2 => Set.new('c', 'g'),
            3 => Set.new('b', 'c', 'g'),
            4 => Set.new('f', 'c', 'd', 'g'),
            5 => Set.new('b', 'd', 'a'),
            6 => Set.new('a', 'b', 'f', 'c'),
            7 => Set.new('a', 'b', 'c', 'd', 'e', 'f', 'g');
    is-deeply get-common-by-length($input), %result, $test;

    $test = 'Can get transliterate string';
    $input = 'acedgfb cdfbe gcdfa fbcad dab cefabd cdfgeb eafb cagedb ab | cdfeb fcadb cdfeb cdbaf';
    $input = get-guesses-and-digits($input).head;
    $result = 'deafgbc';
    is get-trans-string($input), $result, $test;

    $test = 'Can finally solve the number';
    $input = 'acedgfb cdfbe gcdfa fbcad dab cefabd cdfgeb eafb cagedb ab | cdfeb fcadb cdfeb cdbaf';
    $input = get-guesses-and-digits($input).head;
    $result = 5353;
    is get-real-numbers($input), $result, $test;
}