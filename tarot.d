module tarot;

import std.random;
import std.conv;
import std.stdio;
//import combinations;
import std.traits: Unqual;

struct Combinations(T, bool copy=true) {
    Unqual!T[] pool, front;
    size_t r, n;
    bool empty = false;
    size_t[] indices;
    size_t len;
    bool lenComputed = false;
 
    this(T[] pool_, in size_t r_) pure nothrow @safe {
        this.pool = pool_.dup;
        this.r = r_;
        this.n = pool.length;
        if (r > n)
            empty = true;
        indices.length = r;
        foreach (immutable i, ref ini; indices)
            ini = i;
        front.length = r;
        foreach (immutable i, immutable idx; indices)
            front[i] = pool[idx];
    }
 
    @property size_t length() /*logic_const*/ pure nothrow @nogc {
        static size_t binomial(size_t n, size_t k) pure nothrow @safe @nogc
        in {
            assert(n > 0, "binomial: n must be > 0.");
        } body {
            if (k < 0 || k > n)
                return 0;
            if (k > (n / 2))
                k = n - k;
            size_t result = 1;
            foreach (size_t d; 1 .. k + 1) {
                result *= n;
                n--;
                result /= d;
            }
            return result;
        }
 
        if (!lenComputed) {
            // Set cache.
            len = binomial(n, r);
            lenComputed = true;
        }
        return len;
    }
 
    void popFront() pure nothrow @safe {
        if (!empty) {
            bool broken = false;
            size_t pos = 0;
            foreach_reverse (immutable i; 0 .. r) {
                pos = i;
                if (indices[i] != i + n - r) {
                    broken = true;
                    break;
                }
            }
            if (!broken) {
                empty = true;
                return;
            }
            indices[pos]++;
            foreach (immutable j; pos + 1 .. r)
                indices[j] = indices[j - 1] + 1;
            static if (copy)
                front = new Unqual!T[front.length];
            foreach (immutable i, immutable idx; indices)
                front[i] = pool[idx];
        }
    }
}
 
Combinations!(T, copy) combinations(bool copy=true, T)
                                   (T[] items, in size_t k)
in {
    assert(items.length, "combinations: items can't be empty.");
} body {
    return typeof(return)(items, k);
}

enum Couleur { Pique, Carreau, Coeur, Trefle, Atout }

struct Carte
{
    //@disable this();

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

        while(cards.length < 18){
            foreach(index, card; discards){
            }
        }

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

    //misere.combinations(2).map!(x => x).writeln;
	import std.stdio, std.array, std.algorithm;
	misere.combinations!false(2).map!(x => x).writeln;
	misere.combinations!true(2).map!(x => x).writeln;
	misere.combinations(2).map!(x => x).writeln;
}

