module tarot;

import combinations: combinations;
import std.algorithm;
import std.random;
import std.stdio;
import std.conv;
import docopt;
import argvalue;
import game: Deck, Card, Color, petitSec, newStack, show;

Deck give(ref Deck stack, size_t n){
    auto s = stack[0..n];
    stack = stack[n..$];
    return s;
}

void main(string[] args) {
    version(unittest){
        return;
    }
    auto doc = "Tarot simulation.

    Usage:
      tarot --version
      tarot [--players=<n>]

    Options:
      --players=<n>  Number of players in simulation (between 3 and 5) [default: 4]
      -h --help      Show this screen.
      --version      Show version.
    ";
    auto arguments = docopt.docopt(doc, args[1..$], true, "Tarot simulation 1.0");
    //writeln(to!int(arguments["--players"].asInt));
    auto players = to!int(arguments["--players"].toString);

    auto stack = newStack();
    //assert(stack.length == TOTAL_CARDS);

    randomShuffle(stack);

    enum MIN_PLAYER = 3;
    enum MAX_PLAYER = 5;
    if(players < MIN_PLAYER || players > MAX_PLAYER){
            writeln("Bad number of players : ",players);
            return;
    }

    // 78 - 3 = 75, 75 - 45 = 30
    auto decks = new Deck[players];
    enum MIN_CARD = 15;
    enum CARD_PER_TURN = 3;
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
            return;
        }
    }

    /*foreach(deck; decks)*/
    auto deck = decks[0].idup;
    {
        auto taker = deck ~ dog.idup;
        writeln("Size taker : ", taker.length);
        Deck cards;
        Deck discards;
        foreach(card; taker){
            if(card.discardable()){
                discards ~= card;
            } else {
                cards ~= card;
            }
        }

        if(cards.length > deck.length){
            writeln("Exceptional situation, we need to choose between outsiders to create discard stack");
            while(cards.length > deck.length){
                foreach(index, card; cards){
                    if(card.discardable(true)){
                        discards ~= card;
                        cards = cards[0..index] ~ cards[index+1..cards.length];
                        break;
                    }
                }
            }
        }
        auto complement = discards.combinations!false(deck.length - cards.length);
        complement.each!(c => writeln(cards ~ c));

        writeln("Discards: ", discards.length, " : ", discards);
        writeln("Cards: ", cards.length, " : ", cards);
        writeln("Deck: ", deck.length, " : ", deck);
        writeln("Combinations: ", complement.length);
    }
}
