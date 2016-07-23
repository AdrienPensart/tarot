module tarot;

import std.random;
import std.conv;
import std.stdio;

enum Couleur { Pique, Carreau, Coeur, Trefle, Atout }

struct Carte
{
    @disable this();

    this(Couleur c, ubyte v){
        this.c = c;
        this.v = v;
    }

    Couleur c;
    ubyte v;
    bool first;

    public bool master(Carte arg){
        if(c == arg.c){
            return v > arg.v;
        }
        return c == Couleur.Atout;
    }
    
    public bool discardable(bool force=false){
        if(c == Couleur.Atout && v > 1 && v < 21){
            if(force){
                return true;
            }
        }
        else if(v != 14){
            return true;
        }
        return false;
    }
}

alias Carte[] Deck;

void show(Deck deck){
    foreach(d; deck){
        writeln("[",d.v,",",d.c,"]");
    }
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
unittest {
    auto Petit = Carte(Couleur.Atout, 1);
    auto Excuse = Carte(Couleur.Atout, 0);

    Deck misere = [Carte(Couleur.Carreau, 1), Carte(Couleur.Pique, 14), Carte(Couleur.Coeur, 10)];
    Deck atouts = [Carte(Couleur.Atout, 1), Carte(Couleur.Atout, 2)];
    Deck petit = [Petit];
    Deck excuse = [Excuse];

    assert(petitSec(misere) == false);
    assert(petitSec(misere ~ excuse) == false);
    assert(petitSec(misere ~ petit) == true);
    assert(petitSec(misere ~ petit ~ excuse) == false);
    assert(petitSec(misere ~ atouts) == false);
    assert(petitSec(misere ~ atouts ~ petit) == false);
    assert(petitSec(misere ~ atouts ~ petit ~ excuse) == false);
    assert(petitSec(misere ~ atouts ~ excuse) == false);
}

void main() {
    version(unittest){
        return;
    }

    Deck stack;
    foreach(v; 0..22){
        stack ~= Carte(Couleur.Atout, cast(ubyte)v);
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
        
        while(cards.length > 18){
            foreach(index, card; cards){
                if(card.discardable(true)){
                    discards ~= card;
                    cards = cards[0..index] ~ cards[index+1..cards.length];
                    break;
                }
            }
        }
        /*
        while(cards.length < 18){
            foreach(index, card; discards){
                 
            }
        }
        */
        writeln("Discard :");
        show(discards);
        writeln("Jeu du preneur : ");
        show(cards);
        break;
    }

    //show(dog);
    //if(v == 0)
    //    return false;
    //else if(arg.v == 0)
    //    return true;

}
