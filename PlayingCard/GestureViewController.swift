//
//  GestureViewController.swift
//  PlayingCard
//
//  Created by Sneh on 31/08/18.
//  Copyright © 2018 The Gateway Corp. All rights reserved.
//

import UIKit

class GestureViewController: UIViewController {
    var deck = PlayingCardDeck()
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
        override func viewDidLoad() {
            super.viewDidLoad()
            // Do any additional setup after loading the view, typically from a nib.
            print("NO. OF CARDS = \(deck.cards.count) \n\n")
            for _ in 1...10{
                if let card = deck.draw(){
                    print("\(card)")
                }
            }
        }
    
        @IBAction func flipCard(_ sender: UITapGestureRecognizer) {
            switch sender.state {
            case .ended:
                playingCardView.isFaceUp = !playingCardView.isFaceUp
            default:
                break
            }
        }
    
        @IBOutlet weak var playingCardView: PlayingCardView!{
            didSet{
                // It will affect model(PlayingCardDeck), so self will be the target to implement handler, i.e, nextCard
                let swipe = UISwipeGestureRecognizer(target: self, action: #selector(nextCard))
                swipe.direction = [.left,.right]
                playingCardView.addGestureRecognizer(swipe)
    
                let pinch = UIPinchGestureRecognizer(target: playingCardView, action: #selector(PlayingCardView.adjustFaceCardScale(byHandlingGestureRecognizedBy: )))
                playingCardView.addGestureRecognizer(pinch)
            }
        }
    
        @objc func nextCard() {
            if let card = deck.draw(){
                playingCardView.rank = card.rank.order
                playingCardView.suit = card.suit.rawValue
            }
        }

}
