module tarot;

import combinations: combinations;
import std.algorithm;
import std.array;
import std.range;
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
      tarot [options]

    Options:
      --players=<n>      Number of players in simulation (between 3 and 5) [default: 4]
      --max-gen=<n>      Max number of generations to create [default: 1]
      --max-order=<n>    Max number of playing order to create from each discard [default: 1]
      --max-discard=<n>  Max number of discards combinations to create from each generation [default: 1]
      -h --help          Show this screen.
      --version          Show version.
    ";
    auto arguments = docopt.docopt(doc, args[1..$], true, "Tarot simulation 1.0");
    auto players = to!int(arguments["--players"].toString);
    Distribution d = distribution(players);


    /* For each :
        - random generation (1 for the moment)
        - playing mode (3, 4, 5) (1 for the moment)
        - deck (3 possibilities)
        - discard combination
        - order of playing (decks index permutations)
        - combinations of deck play following game rules
    */
    writeln("Number of decks: ", d.decks.length);
    foreach(deck; d.decks){
        Deck cards;
        Deck discardables;
        foreach(card; deck ~ d.dog){
            if(card.discardable()){
                discardables ~= card;
            } else {
                cards ~= card;
            }
        }
        if(cards.length > deck.length){
            writeln("Exceptional situation, we need to choose between outsiders to complete discard.");
            while(cards.length > deck.length){
                foreach(index, card; cards){
                    if(card.discardable(true)){
                        discardables ~= card;
                        cards = cards[0..index] ~ cards[index+1..cards.length];
                        break;
                    }
                }
            }
        }
        writeln("  Discardables: ", discardables);
        writeln("  Discardables value: ", discardables.points);
        auto discards = discardables.combinations(deck.length - cards.length);
        writeln("  Deck length: ", deck.length, " and cards length: ", cards.length);
        writeln("  Discard: ", discards.length);
        foreach(complement ; discards){
            auto discardPoints = discardables.points - complement.points;
            writeln("    Discard value: ", discardPoints);
            auto game = cards ~ complement;
            assert(game.length == deck.length);
            auto turns = iota(0, d.decks.length).permutations;
            writeln("    Complement: ", complement);
            writeln("    Game: ", game);
            writeln("    Game size: ", game.length);
            writeln("    Permutations of turns: ", array(turns).length);
            foreach(turn; turns){
                writeln(turn);
                foreach(index; turn)
                {
                    writeln("Playing ", index);
                }
                break;
            }
            break;
        }
        break;
    }
}
