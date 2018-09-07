//
//  PlayingCard.swift
//  PlayingCard
//
//  Created by Sneh on 23/08/18.
//  Copyright © 2018 The Gateway Corp. All rights reserved.
//

import Foundation

struct PlayingCard: CustomStringConvertible
{
    var description: String{ return "\(rank)\(suit)"}
    
    var suit: Suit
    var rank: Rank
    
    
    enum Suit: String,CustomStringConvertible
    {
        
        var description: String{ return rawValue }
        
        //giving Raw values means assigning unique values
        
        //DEFAULT values for cases will be as following if we dont assign xplicitly unique values...
        //cases will get raw values in increasing order(i.e, 0,1,2...) due to writing colon Int besides Suit
        //cases will get raw values as cases of string version(i.e. "spades",..) due to writing colon String besides Suit
        case spades = "♠️"
        case hearts = "♥️"
        case clubs = "♣️"
        case diamonds = "♦️"
        static var all = [Suit.spades,.hearts,.diamonds,.clubs]
    }
    
    enum Rank: CustomStringConvertible
    {
        // BEST rept of rank but prof. wants to show with associated data
        //        case ace
        //        case two
        //        case three
        //
        //        case jack
        //        case queen
        //        case king
        
        case ace
        case face(String) //here assoc. data will be (J,Q,K)
        case numeric(Int) //here assoc. data will be (2...10 (pipscount)) NOTE : card 2 has 2 pips, 3 has 3 pips nd show on
        
        var order: Int{
            //read only prop
            switch self
            {
            case .ace: return 1
            case .numeric(let pips): return pips //for my numeric rank I will get num. of pips nd return it bcoz that my num
            
            //                case .face(let kind):
            //                if kind == "J" {return 11}
            //                else if kind == "Q" {return 12}
            //                else return 13
            
            //                OR (Swift is pattern matching language)
                
            case .face(let kind) where kind == "J": return 11
            case .face(let kind) where kind == "Q": return 12
            case .face(let kind) where kind == "K": return 13
            
            default: return 0
            }
        }
        
        static var all: [Rank]
        {
            var allRanks = [Rank.ace]
        
            for pips in 2...10{
                allRanks.append(Rank.numeric(pips))
            }
            
            //allRanks += [Rank.face("J"),Rank.face("Q"),Rank.face("K")]
            // OR
            allRanks += [Rank.face("J"),.face("Q"),.face("K")]
            return allRanks
        }
        
        var description: String{  //return "\(self.order)"
            switch  self {
            case .ace: return "A"
            case .numeric(let pips): return String(pips)
            case .face(let kind): return kind
        }
     }
   }
}
