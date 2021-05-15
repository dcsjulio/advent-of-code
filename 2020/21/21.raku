#!/usr/bin/env raku

my %data;
my @all-ingredients;

for 'input'.IO.slurp ~~ m:g/(\w+)+ %% ' ' '(contains ' (\w+)+ % ', ' ')'/ -> $match {
    my @ingredients := $match[0].map(~*).list;
    @all-ingredients.push: $_ for @ingredients;
    for $match[1] -> $alergen {
        if %data{$alergen}:exists {
            %data{$alergen} ∩= @ingredients;
        } else {
            %data{$alergen} = Set.new: @ingredients;
        }
    }
}

my @bad-ingredients := %data.map(*.value.keys).flat.unique.list;
say 'Case 1: ' ~ elems @all-ingredients.grep: * eq none @bad-ingredients;

sub find-next-alergen {
    state @reduced;

    my $new = %data
        .grep(*.value.keys.elems == 1)
        .map(*.value.keys.head)
        .grep(* eq none @reduced)
        .head;

    @reduced.push($new) if $new;
    $new
}

sub remove-alergen($to-remove) {
    for %data.kv -> $alergen, $ingredients {
        next if $ingredients.list.elems == 1;
        %data{$alergen} = $ingredients.list ∖ $to-remove
    }
}

remove-alergen $_ while $_ = find-next-alergen;
say 'Case 2: ' ~ %data.keys.sort.map({ %data{$_}.map: *.keys }).flat.join: ',';
