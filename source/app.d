module tarot;

import combinations: combinations;
import std.algorithm;
import std.array;
import std.range;
import std.random;
import std.stdio;
import std.conv;
import docopt;
import argvalue;
import deck;
import game;
import player;

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
            writeln("Can't continue with petit sec in deck");
            return;
        }
    }
    /* For each :
        - random generation (1 for the moment)
        - playing mode (3, 4, 5) (1 for the moment)
        - deck (3 possibilities)
        - discard combination
        - order of playing (decks index permutations)
        - combinations of deck play following game rules
    */
    foreach(deck; decks){
        Deck cards;
        Deck discards;
        foreach(card; deck ~ dog){
            if(card.discardable()){
                discards ~= card;
            } else {
                cards ~= card;
            }
        }
        if(cards.length > deck.length){
            writeln("Exceptional situation, we need to choose between outsiders to complete discard.");
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
        auto complement = discards.combinations(deck.length - cards.length);
        foreach(c ; complement){
            auto game = cards ~ c;
            assert(game.length == deck.length);
            auto turns = iota(0, decks.length).permutations;
            foreach(turn; turns){
                writeln(turn);
                foreach(index; turn)
                {
                    writeln("Playing ", index);
                }
            }
        }
    }
}
