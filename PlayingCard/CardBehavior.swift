//
//  CardBehavior.swift
//  PlayingCard
//
//  Created by Sneh on 03/09/18.
//  Copyright © 2018 The Gateway Corp. All rights reserved.
//

import UIKit

class CardBehavior: UIDynamicBehavior {
    
    //Here closure is assigned with var
    lazy var collisionBehavior: UICollisionBehavior = {
        let behavior = UICollisionBehavior()
        behavior.translatesReferenceBoundsIntoBoundary = true
        //animator.addBehavior(behavior)
        return behavior
    }()
    
    lazy var itemBehavior: UIDynamicItemBehavior = {
        let behavior = UIDynamicItemBehavior()
        behavior.allowsRotation = false
        behavior.elasticity = 0.9 //Acceleration after collision
        behavior.resistance = 0
        //animator.addBehavior(behavior)
        return behavior
    }()
    
    private func push(_ item: UIDynamicItem){
        //Now we will move the card
        let push = UIPushBehavior(items: [item], mode: .instantaneous) // here it is only one card that is push not array of cards
        
        // push.angle = (2*CGFloat.pi).arc4random	
        
        // CODE TO PUSH SOMETHING TOWARDS CENTER
        if let referenceBounds = dynamicAnimator?.referenceView?.bounds {
            let center = CGPoint(x: referenceBounds.midX, y: referenceBounds.midY)
            switch (item.center.x, item.center.y) {
            case let (x, y) where x < center.x && y < center.y:
                push.angle = (CGFloat.pi/2).arc4random
            case let (x, y) where x > center.x && y < center.y:
                push.angle = CGFloat.pi-(CGFloat.pi/2).arc4random
            case let (x, y) where x < center.x && y > center.y:
                push.angle = (-CGFloat.pi/2).arc4random
            case let (x, y) where x > center.x && y > center.y:
                push.angle = CGFloat.pi+(CGFloat.pi/2).arc4random
            default:
                push.angle = (CGFloat.pi*2).arc4random
            }
        }
        
        //magnitude means vector length irrespective of its direction
        push.magnitude = CGFloat(1.0)+CGFloat(2.0).arc4random // It gives random magnitude between 1 and 3
        
        //Cleaning the m/m
        
        //        push.action = { [unowned push] in
        //            push.dynamicAnimator?.removeBehavior(push)
        //        }
        push.action = { [unowned push, weak self] in
            self?.removeChildBehavior(push)
        }
        // Y to use weak here?
        // self has a pntr to push behavior nd push behavior has pntr. to closure which points back to self...
        // So to break m/m cycle
        // If we use unowned instead of weak self, then if due to any reason the push behavior get remove from m/m then we dont need
        // to crash whole prog.
        
        
        addChildBehavior(push)
        
        //animator.addBehavior(push)
        //Atla code pachi prblm ee hse k collision pachi bau elasticity ni hoi etle k cards ma energy ni hoi to bounce off after collosion.. wrote code of itemBehavior after this
    }
    
    func addItem(_ item: UIDynamicItem){
        collisionBehavior.addItem(item)
        itemBehavior.addItem(item)
        push(item)
    }
    
    func removeItem(_ item: UIDynamicItem){
        collisionBehavior.removeItem(item)
        itemBehavior.removeItem(item)
    }

    //99.99% times when u r using dynamic behavior always override init...
    override init() {
        super.init()
        addChildBehavior(collisionBehavior)
        addChildBehavior(itemBehavior)
    }
    
    convenience init(in animator: UIDynamicAnimator) {
        self.init()
        animator.addBehavior(self)
    }
}

