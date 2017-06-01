module game;

import deck;
import card;

import std.typecons;
import std.conv;
import std.stdio;
import std.algorithm;
import combinations: combinations;

enum MIN_PLAYER = 3;
enum MAX_PLAYER = 5;
enum MIN_CARD = 15;
enum CARD_PER_TURN = 3;

static auto exceptionGenerator(string ex)
{
    return "
		class " ~ ex ~ " : Exception
	    {
    	    this(string msg=\"" ~ ex ~ "\", string file = __FILE__, size_t line = __LINE__) {
        	    super(msg, file, line);
	        }
    	}";
}

// petit sec
mixin(exceptionGenerator("InvalidDistribution"));
mixin(exceptionGenerator("InvalidPlayers"));


alias Distribution = Tuple!(Deck[], "decks", Deck, "dog");


auto distribution(int players) {
    auto stack = newStack();
    if(players < MIN_PLAYER || players > MAX_PLAYER){
		throw new InvalidPlayers();
    }

    auto decks = new Deck[players];
    Deck dog = stack.give(CARD_PER_TURN);
    foreach(p; 0..players){
        decks[p] ~= stack.give(MIN_CARD);
    }
    while(((cast(int)stack.length - CARD_PER_TURN) / players) > CARD_PER_TURN - 1){
        foreach(p; 0..players){
            decks[p] ~= stack.give(CARD_PER_TURN);
        }
    }
    dog ~= stack.give(stack.length);
    foreach(i, deck; decks){
        if(deck.petitSec){
			throw new InvalidDistribution();
        }
    }
	return tuple(decks, dog);
}

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
