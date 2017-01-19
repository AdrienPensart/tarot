module deck;

import std.stdio;
import card;

alias Card[] Deck;

auto show(Deck deck){
    foreach(d; deck){
        write("[",d,"]");
    }
    return deck;
}

auto points(Deck deck)
{
    float p = 0.0;
    foreach(d; deck)
    {
        p += d.points;
    }
    return p;
}

auto newStack()
{
    Deck stack;
    foreach(ubyte v; 0..22){
        stack ~= Card(Color.Atout, v);
    }
    foreach(c; [Color.Pique, Color.Carreau, Color.Coeur, Color.Trefle]){
        foreach(ubyte v; 1..15){
            stack ~= Card(c, v);
        }
    }
    return stack;
}

bool petitSec(Deck deck){
    int numberAtouts = 0;
    bool petitFound = false;
    foreach(card; deck){
        if(card.c == Color.Atout) {
            numberAtouts++;
            petitFound = petitFound || (card.v == 1);
        }
    }
    return petitFound && (numberAtouts == 1);
}
