module card;

import std.stdio;
import std.conv;

enum TOTAL_CARDS = 78;
auto Petit = Card(Color.Atout, 1);
auto Excuse = Card(Color.Atout, 0);

string declare(ubyte v){
    return "auto _" ~ to!string(v) ~ " = Card(Color.Atout, " ~ to!string(v) ~ ");";
}

string declareAll(){
    string all;
    foreach(ubyte i; 1..22){
        all ~= declare(i);
    }
    return all;
}

mixin(declareAll());

enum Color{
    Pique,
    Carreau,
    Coeur,
    Trefle,
    Atout
}

wstring[Color] mapping;
static this(){
    mapping =  [Color.Pique:r"♠", Color.Carreau:r"♦", Color.Trefle:r"♣", Color.Coeur:r"♥"];
}

struct Card{
    this(Color c, ubyte v){
        this.c = c;
        this.v = v;
    }

    Color c;
    ubyte v;

    wstring toString() const {
        if(c == Color.Atout){
            if(v == 0){
                return r"🃏";
            }
            return to!wstring(v) ~ r"🂠";
        } else {
            return to!wstring(v) ~ mapping[c];
        }
    }

    invariant{
        assert(c == Color.Pique || c == Color.Carreau || c == Color.Coeur || c == Color.Trefle || c == Color.Atout);
        static if(c == Color.Atout){
            assert(v >= 0);
            assert(v <= 21);
        } else {
            assert(v > 0);
            assert(v <= 14);
        }
    }

    public const pure @safe nothrow{
        bool master(Card arg){
            if(c == arg.c){
                return v > arg.v;
            }
            return c == Color.Atout;
        }

        bool discardable(bool force=false){
            if(c == Color.Atout){
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
            if (c == Color.Atout){
                if(v == 0 || v == 1 || v == 21){
                    return 4.5;
                }
                return 0.5;
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

unittest{
    assert(Excuse.discardable == false);
    assert(Petit.discardable == false);
    assert(_21.discardable == false);

    auto c = new Card(Color.Coeur, 0);
}
