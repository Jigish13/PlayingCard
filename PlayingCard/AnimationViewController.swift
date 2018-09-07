//
//  ViewController.swift
//  PlayingCard
//
//  Created by Sneh on 22/08/18.
//  Copyright © 2018 The Gateway Corp. All rights reserved.
//

import UIKit

class AnimationViewController: UIViewController {
    
    var deck = PlayingCardDeck()
    
    
    @IBOutlet private var cardViews: [PlayingCardView]!
    
    //For motion animation... logic is.. animator -> behavior -> item
    //view here keeps the ref. of superview that I m in i.e. PlayingCard
    lazy var animator = UIDynamicAnimator(referenceView: view)
    
    lazy var cardBehavior = CardBehavior(in: animator)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var cards = [PlayingCard]()
        for _ in 1...((cardViews.count + 1)/2){
            let card = deck.draw()!
            cards += [card,card]
        }
        for cardView in cardViews{
            cardView.isFaceUp = false
            let card = cards.remove(at: cards.count.arc4random)
            cardView.rank = card.rank.order
            cardView.suit = card.suit.rawValue
            cardView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(flipCard(_:))))
            
            //Add items to the collision behaviour here
            // collisionBehavior.addItem(cardView)
            // itemBehavior.addItem(cardView)
            cardBehavior.addItem(cardView)
            
        }
    }
    
    //Computed prop. to check whether 2 cards r faced up or not. if YES then flip it over...
    private var faceUpCardViews: [PlayingCardView]{
        return cardViews.filter { $0.isFaceUp && !$0.isHidden && $0.transform != CGAffineTransform.identity.scaledBy(x: 3.0, y: 3.0) && $0.alpha == 1}
    }
    
    //Bool that will tell two faceUp cards matches or not
    private var faceUpCardViewsMatch: Bool{
        return faceUpCardViews.count == 2 && faceUpCardViews[0].rank == faceUpCardViews[1].rank && faceUpCardViews[0].suit == faceUpCardViews[1].suit
    }
    
    //NOTE: 2 face up cards nu transition animation nu duration 3 kariye to else-if vadi cond na lidhe animation mess-up thai jse
    //So we will wait for 2nd card or latest to flip over transition again
    var lastChosenCardView: PlayingCardView?
    
    @objc private func flipCard(_ recognizer: UITapGestureRecognizer){
        switch recognizer.state {
        case .ended:
            if let chosenCardView = recognizer.view as? PlayingCardView, faceUpCardViews.count < 2{
            lastChosenCardView = chosenCardView
            cardBehavior.removeItem(chosenCardView)
            UIView.transition(
                with: chosenCardView,
                duration: 0.6,
                options: [.transitionFlipFromLeft],
                animations: {
                    chosenCardView.isFaceUp = !chosenCardView.isFaceUp
                },
                completion: { finished in
                    
                    let cardsToAnimate = self.faceUpCardViews //Inorder to keep track of that 2 cards selected
                    
                    if self.faceUpCardViewsMatch
                    {
                     UIViewPropertyAnimator.runningPropertyAnimator(
                        withDuration: 0.6,
                        delay: 0,
                        options: [],
                        animations: {
                            cardsToAnimate.forEach {
                                $0.transform = CGAffineTransform.identity.scaledBy(x: 3.0, y: 3.0)
                            }
                        },
                        completion: { position in
                            UIViewPropertyAnimator.runningPropertyAnimator(
                                withDuration: 0.75,
                                delay: 0,
                                options: [],
                                animations: {
                                    cardsToAnimate.forEach {
                                        $0.transform = CGAffineTransform.identity.scaledBy(x: 0.1, y: 0.1)
                                        $0.alpha = 0
                                    }},
                                completion: { position in
                                    //CLEAN-UP code goes here i.e. after match of two cards they wont be used for matches
                                    cardsToAnimate.forEach {
                                       $0.isHidden = true
                                       //Now matched cards r hidden so we can do clean up by making it appear as it be exec. due to above line
                                        
                                        //INORDER to remove the cards from view hierarchy which r hidden nd transparent, do as follow
                                       $0.alpha = 1
                                       $0.transform = .identity
                                    }
                                }
                            )
                        })
                    }else if cardsToAnimate.count == 2 {
                        if chosenCardView == self.lastChosenCardView {
                            //
                            // IF there r two unmatched cards just flip them over
                            //
                            //Here there is no need to do local var's like weak coz there is no m/m cycle here as closure has pointer
                            //to self but self dont has the same...
                            //HERE it is forEach closure
                            cardsToAnimate.forEach { cardView in
                                UIView.transition(
                                    with: cardView,
                                    duration: 0.6,
                                    options: [.transitionFlipFromLeft],
                                    animations: {
                                        cardView.isFaceUp = false
                                },
                                    completion: { finished in
                                        self.cardBehavior.addItem(cardView)
                                }
                                )
                            }
                        }
                    } else {
                        // IF it is one card then jus flip it over nd push it...
                        if !chosenCardView.isFaceUp{
                            self.cardBehavior.addItem(chosenCardView)
                        }
                    }
                }
              )
            }
        default: break
        }
    }
}

//extension CGFloat{
//    var arc4random: CGFloat{
//        if self > 0 { return CGFloat(arc4random_uniform(UInt32(self))) }
//        else if self < 0 { return -CGFloat(arc4random_uniform(UInt32(self))) }
//        else { return 0 }
//    }
//}


