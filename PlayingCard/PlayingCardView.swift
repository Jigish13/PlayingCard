//
//  PlayingCardView.swift
//  PlayingCard
//
//  Created by Sneh on 23/08/18.
//  Copyright © 2018 The Gateway Corp. All rights reserved.
//

import UIKit

@IBDesignable
class PlayingCardView: UIView {
    
    @IBInspectable
    var rank: Int = 11{
        //Code will be executed when rank changes
        didSet{
            setNeedsDisplay() //Will be called when rank 5 changes to suppose 11, ie. we need to redraw
            setNeedsLayout()   // Will be called as we need to layout sub views when our view(i.e. top view string) gets changed
        }
    }
    
    
    @IBInspectable
    var suit: String = "♥️"{
        didSet{
            setNeedsDisplay()
            setNeedsLayout()
        }
    }
    
    
    @IBInspectable
    var isFaceUp: Bool = true{
        didSet{
            setNeedsDisplay()
            setNeedsLayout()
        }
    }
    
    
    var faceCardScale: CGFloat = SizeRatio.faceCardImageSizeToBoundsSize{
        didSet{
            setNeedsDisplay()
            //setNeedsLayout() = No need to re-layout as zooming wont affect corner strings
        }
    }
    
    //Handler for pinch gesture
    @objc func adjustFaceCardScale(byHandlingGestureRecognizedBy recognizer: UIPinchGestureRecognizer){
        switch recognizer.state{
        case .changed,.ended:
            faceCardScale *= recognizer.scale
            recognizer.scale = 1.0
        default: break
        }
    }
    
    
    private func centeredAttributedString(_ string: String, fontSize: CGFloat) -> NSAttributedString {
        //Code to dynamically scale the font size as per setting in Accessibility from Settings
        var font = UIFont.preferredFont(forTextStyle: .body).withSize(fontSize)
        font = UIFontMetrics(forTextStyle: .body).scaledFont(for: font)
        
        //Code to allign paragraph to
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        return NSAttributedString(string: string, attributes: [.paragraphStyle:paragraphStyle , .font: font])
    }
    
    private var cornerString: NSAttributedString {
        return centeredAttributedString(rankString + "\n" + suit, fontSize: cornerFontSize)
    }

    //In lect, prof shows drawing by both method :
    // 1. by SubView
    // 2. by drawRect
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    //DEMO to draw circle in my rect/bound area
    
    //    override func draw(_ rect: CGRect) {
    //        // Drawing code usign Core Graphics
    //        //In this method, we will always get context, otherwise may be it return nil...
    //        // NOTE: bounds rept my rect or drawing area so we can use that to find center of circle
    //            //        if let context = UIGraphicsGetCurrentContext(){
    //            //            context.addArc(center: CGPoint(x: bounds.midX, y: bounds.midY), radius: 100.0, startAngle: 0, endAngle: 2*CGFloat.pi, clockwise: true)
    //            //            context.setLineWidth(5.0)
    //            //            UIColor.green.setFill()
    //            //            UIColor.red.setStroke()
    //            //            context.strokePath()
    //            //            context.fillPath() }//It wont fill the path, as it actually consumes the path by stroking it,
    //            //so there will be no path to fill it
    //            //Thus, use bezier path method to draw
    //
    //
    //            // Drawing code usign BEZIER method...
    //
    //            let path = UIBezierPath()
    //            path.addArc(withCenter: CGPoint(x: bounds.midX, y: bounds.midY), radius: 100.0, startAngle: 0, endAngle: 2*CGFloat.pi, clockwise: true)
    //            path.lineWidth = 5.0
    //            UIColor.green.setFill()
    //            UIColor.red.setStroke()
    //            path.stroke()
    //            path.fill()
    //    }
    
    //lazy bcoz untill self is fully initialized we cannot call methods on ourselves
    lazy private var upperLeftCornerLabel = createCornerLabel()
    lazy private var lowerRightCornerLabel = createCornerLabel()
    
    private func createCornerLabel() -> UILabel {
        let label = UILabel()
        label.numberOfLines = 0 // 0 means use as many as lines u need, 1 is by default then only rank will be displayed
        addSubview(label) //means add subview to myshelf
        return label
    }
    
    private func configureCornerLabel(_ label: UILabel){
        label.attributedText = cornerString
        label.frame.size = CGSize.zero // i.e label width & height will be 0 as sizeToFit() will only be resizeing its height
        label.sizeToFit() // means content na hisaabe label ne resize kro
        label.isHidden = !isFaceUp //Jus hide the card when I am not face up
    }
    
    
    //Final step to be done to dynamically change size of font,when user changes it...
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        setNeedsDisplay()
        setNeedsLayout()
    }
    
    //layoutSubviews() Will be called autometically when u call setNeedsLayout, i.e, to lay sub views
    //Override this method when due to any reason, the bounds of rect changes
    //Now anytime the sub views need to be layed out this is called autometically by the system as in AutoLayout
    override func layoutSubviews() {
        super.layoutSubviews()
        
        configureCornerLabel(upperLeftCornerLabel)
        
        //Note :frame rept where to position/set it nd bound rept where to draw in it(i.e. View)
        //Means set origin of upperLeftCornerLabel to (dx,dy) distance from origin of bounds of me(i.e PLaying Card)
        // frame boleto parent na respect ma my posn. nd bound boleto my drawing area that is custom view
        upperLeftCornerLabel.frame.origin = bounds.origin.offsetBy(dx: cornerOffset, dy: cornerOffset)
        
        
        configureCornerLabel(lowerRightCornerLabel)
        lowerRightCornerLabel.transform = CGAffineTransform.identity.translatedBy(x: lowerRightCornerLabel.frame.size.width, y: lowerRightCornerLabel.frame.size.height).rotated(by: CGFloat.pi)
        lowerRightCornerLabel.frame.origin = CGPoint(x: bounds.maxX, y: bounds.maxY).offsetBy(dx: -cornerOffset, dy: -cornerOffset).offsetBy(dx: -lowerRightCornerLabel.frame.size.width, dy: -lowerRightCornerLabel.frame.size.height)
    }
    
    private func drawPips()
    {
        let pipsPerRowForRank = [[0],[1],[1,1],[1,1,1],[2,2],[2,1,2],[2,2,2],[2,1,2,2],[2,2,2,2],[2,2,1,2,2],[2,2,2,2,2]]
        
        func createPipString(thatFits pipRect: CGRect) -> NSAttributedString {
            let maxVerticalPipCount = CGFloat(pipsPerRowForRank.reduce(0) { max($1.count, $0) })
            //print("maxVerticalPipCount: \(maxVerticalPipCount)")
            let maxHorizontalPipCount = CGFloat(pipsPerRowForRank.reduce(0) { max($1.max() ?? 0, $0) })
            //print("maxHorizontalPipCount: \(maxHorizontalPipCount)")
            let verticalPipRowSpacing = pipRect.size.height / maxVerticalPipCount
            let attemptedPipString = centeredAttributedString(suit, fontSize: verticalPipRowSpacing)
            let probablyOkayPipStringFontSize = verticalPipRowSpacing / (attemptedPipString.size().height / verticalPipRowSpacing)
            let probablyOkayPipString = centeredAttributedString(suit, fontSize: probablyOkayPipStringFontSize)
            if probablyOkayPipString.size().width > pipRect.size.width / maxHorizontalPipCount {
                return centeredAttributedString(suit, fontSize: probablyOkayPipStringFontSize / (probablyOkayPipString.size().width / (pipRect.size.width / maxHorizontalPipCount)))
            } else {
                return probablyOkayPipString
            }
        }
        
        if pipsPerRowForRank.indices.contains(rank) {
            let pipsPerRow = pipsPerRowForRank[rank]
            //print("pipsPerRow: \(pipsPerRow)")
            var pipRect = bounds.insetBy(dx: cornerOffset, dy: cornerOffset).insetBy(dx: cornerString.size().width, dy: cornerString.size().height / 2)
            let pipString = createPipString(thatFits: pipRect)
            //print("pipString: \(pipString)")
            let pipRowSpacing = pipRect.size.height / CGFloat(pipsPerRow.count)
            pipRect.size.height = pipString.size().height
            pipRect.origin.y += (pipRowSpacing - pipRect.size.height) / 2
            for pipCount in pipsPerRow {
                switch pipCount {
                case 1:
                    pipString.draw(in: pipRect)
                case 2:
                    pipString.draw(in: pipRect.leftHalf)
                    pipString.draw(in: pipRect.rightHalf)
                default:
                    break
                }
                pipRect.origin.y += pipRowSpacing
            }
        }
    }
    
    
    //Will be called autometically when u call setNeedsDisplay, i.e, to redraw
    override func draw(_ rect: CGRect) {
        let roundedRect = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius)
        roundedRect.addClip() // means all things the from here will be inside my rounded rect. area
        UIColor.white.setFill()
        roundedRect.fill()
        
        if isFaceUp{
        //CONCEPT : To put image, get it by name nd put it in some rect...
            // in parameter in below ctor is used to see the image in storyboard
        if let faceCardImage = UIImage(named: rankString+suit, in: Bundle(for: self.classForCoder), compatibleWith: traitCollection){
            faceCardImage.draw(in: bounds.zoom(by: faceCardScale))
            } else{
            drawPips()
            }
        }
        else {
             if let cardBackImage = UIImage(named: "cardback", in: Bundle(for: self.classForCoder), compatibleWith: traitCollection) {
                cardBackImage.draw(in: bounds)
                }
             }
    }
    
}

extension PlayingCardView {
    //Way to use constants in iOS
    private struct SizeRatio {
        static let cornerFontSizeToBoundsHeight: CGFloat = 0.085
        static let cornerRadiusToBoundsHeight: CGFloat = 0.06
        static let cornerOffsetToCornerRadius: CGFloat = 0.33
        static let faceCardImageSizeToBoundsSize: CGFloat = 0.75
    }
    private var cornerRadius: CGFloat {
        return bounds.size.height * SizeRatio.cornerRadiusToBoundsHeight
    }
    private var cornerOffset: CGFloat {
        return cornerRadius * SizeRatio.cornerOffsetToCornerRadius
    }
    private var cornerFontSize: CGFloat {
        return bounds.size.height * SizeRatio.cornerFontSizeToBoundsHeight
    }
    private var rankString: String {
        switch rank {
        case 1: return "A"
        case 2...10: return String(rank)
        case 11: return "J"
        case 12: return "Q"
        case 13: return "K"
        default: return "?"
        }
    }
}

extension CGRect {
    var leftHalf: CGRect {
        return CGRect(x: minX, y: minY, width: width/2, height: height)
    }
    var rightHalf: CGRect {
        return CGRect(x: midX, y: minY, width: width/2, height: height)
    }
    func inset(by size: CGSize) -> CGRect {
        return insetBy(dx: size.width, dy: size.height)
    }
    func sized(to size: CGSize) -> CGRect {
        return CGRect(origin: origin, size: size)
    }
    func zoom(by scale: CGFloat) -> CGRect {
        let newWidth = width * scale
        let newHeight = height * scale
        return insetBy(dx: (width - newWidth) / 2, dy: (height - newHeight) / 2)
    }
}

extension CGPoint {
    func offsetBy(dx: CGFloat, dy: CGFloat) -> CGPoint {
        return CGPoint(x: x+dx, y: y+dy)
    }
}
extension CGFloat {
    var arc4random: CGFloat {
        return self * (CGFloat(arc4random_uniform(UInt32.max))/CGFloat(UInt32.max))
    }
}
