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
    Deck atouts = [_1, _2];
    Deck petit = [Petit];
    Deck excuse = [Excuse];

    assert(Excuse.discardable == false);
    assert(Petit.discardable == false);
    assert(_21.discardable == false);

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

    auto stack = newStack();
    assert(stack.length == 78);
    assert(stack.points == 91);

    foreach(s; stack)
    {
        if(s.points == 4.5)
        {
            assert(s.discardable() == false);
            assert(s.discardable(true) == false);
        }
        else if(s.c == Color.Atout)
        {
            assert(s.discardable() == false);
            assert(s.discardable(true) == true);
        }
        else
        {
            assert(s.discardable() == true);
        }
    }
}
