module tarot;

import combinations: combinations;
import std.algorithm;
import std.random;
import std.conv;
import std.stdio;

auto Petit = Carte(Couleur.Atout, 1);
auto Excuse = Carte(Couleur.Atout, 0);

string declare(ubyte v){
    return "auto _" ~ to!string(v) ~ " = Carte(Couleur.Atout, " ~ to!string(v) ~ ");";
}

string declareAll(){
    string all;
    foreach(ubyte i; 1..22){
        all ~= declare(i);
    }
    return all;
}

mixin(declareAll());

enum Couleur { Pique, Carreau, Coeur, Trefle, Atout }

struct Carte
{
    this(Couleur c, ubyte v){
        this.c = c;
        this.v = v;
    }

    Couleur c;
    ubyte v;

    invariant{
        assert(c == Couleur.Pique || c == Couleur.Carreau || c == Couleur.Coeur || c == Couleur.Trefle || c == Couleur.Atout);
        if(c == Couleur.Atout){
            assert(v >= 0 && v <= 21);
        } else {
            assert(v >= 0 && v <= 14);
        }
    }

    public pure @safe nothrow{
        bool master(Carte arg){
            if(c == arg.c){
                return v > arg.v;
            }
            return c == Couleur.Atout;
        }

        bool discardable(bool force=false){
            if(c == Couleur.Atout){
                if(v == 0 || v == 1 || v == 21){
                    return false;
                }
                if(force){
                    return true;
                }
            }
            else if(v != 14){
                return true;
            }
            return false;
        }

        float points(){
            if (c == Couleur.Atout && (v == 0 || v == 1 || v == 21)){
                return 4.5;
            }
            if (v == 14){
                return 4.5;
            }
            if (v == 13){
                return 3.5;
            }
            if (v == 12){
                return 2.5;
            }
            if (v == 11){
                return 1.5;
            }
            return 0.5;
        }
    }
}

alias Carte[] Deck;

auto show(Deck deck){
    foreach(d; deck){
        write("[",d.v,",",d.c,"]");
    }
    return deck;
}

bool petitSec(Deck deck){
    int numberAtouts = 0;
    bool petitFound = false;
    foreach(card; deck){
        if(card.c == Couleur.Atout) {
            numberAtouts++;
            petitFound = petitFound || (card.v == 1);
        }
    }
    return petitFound && (numberAtouts == 1);
}

void main() {
    version(unittest){
        return;
    }

    Deck stack;
    foreach(ubyte v; 0..22){
        stack ~= Carte(Couleur.Atout, v);
    }
    foreach(c; [Couleur.Pique, Couleur.Carreau, Couleur.Coeur, Couleur.Trefle]){
        foreach(v; 1..15){
            stack ~= Carte(c, cast(ubyte)v);
        }
    }
    writeln("Stack size :", stack.length);
    randomShuffle(stack);

    Deck[4] decks;
    Deck dog = stack[0..6];
    decks[0] = stack[6..24];
    decks[1] = stack[24..42];
    decks[2] = stack[42..60];
    decks[3] = stack[60..77];

    foreach(deck; decks){
        if(deck.petitSec){
            writeln("PetitSec");
            return;
        }
    }

    foreach(deck; decks){
        Deck taker = decks[0] ~ dog;
        writeln("Size taker :", taker.length);
        Deck cards;
        Deck discards;
        foreach(card; taker){
            if(card.discardable()){
                discards ~= card;
            } else {
                cards ~= card;
            }
        }

        if(cards.length > 18){
            writeln("Exceptional situation, we need to choose between outsiders to create discard stack");
            while(cards.length > 18){
                foreach(index, card; cards){
                    if(card.discardable(true)){
                        discards ~= card;
                        cards = cards[0..index] ~ cards[index+1..cards.length];
                        break;
                    }
                }
            }
        }

        writeln("Discards:", discards);
        writeln("Cards:", cards);
        if(cards.length < 18){
            writeln("Computing combinations: ", 24 - discards.length);
            discards.combinations!false(24 - discards.length).map!(x => x).writeln;
        }
        break;
    }
}

unittest {
    Deck misere = [Carte(Couleur.Carreau, 1), Carte(Couleur.Pique, 14), Carte(Couleur.Coeur, 10)];
    Deck atouts = [_1, _2];
    Deck petit = [Petit];
    Deck excuse = [Excuse];

    assert(Excuse.discardable() == false);
    assert(Petit.discardable() == false);
    assert(_21.discardable() == false);

    assert(petitSec(misere) == false);
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
}

