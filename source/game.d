module game;

import deck;
import card;

import std.conv;
import std.stdio;
import std.algorithm;
import combinations: combinations;

unittest {
    Deck discardable;
    foreach(c; [Color.Pique, Color.Carreau, Color.Coeur, Color.Trefle]){
        foreach(ubyte v; 1..14){
            discardable ~= Card(c, v);
        }
    }

    Deck misere = [Card(Color.Carreau, 1), Card(Color.Pique, 14), Card(Color.Coeur, 10)];
    Deck atouts = [_1, _2, _3];
    Deck petit = [Petit];
    Deck excuse = [Excuse];

    assert(misere.petitSec == false);
    assert(petitSec(misere ~ excuse) == false);
    assert(petitSec(misere ~ petit) == true);
    assert(petitSec(misere ~ petit ~ excuse) == false);
    assert(petitSec(misere ~ atouts) == false);
    assert(petitSec(misere ~ atouts ~ petit) == false);
    assert(petitSec(misere ~ atouts ~ petit ~ excuse) == false);
    assert(petitSec(misere ~ atouts ~ excuse) == false);

    assert(equal(misere.combinations!false(2), misere.combinations(2)));
    assert(equal(misere.combinations!true(2), misere.combinations(2)));
    assert(equal(misere.combinations!false(2), misere.combinations!true(2)));

    // 7 cars not discardable at all
    // 26 not discardable
    // 52 discardable
    assert(discardable[0..24].combinations(6).map!(x => x).length == 134596);
}
