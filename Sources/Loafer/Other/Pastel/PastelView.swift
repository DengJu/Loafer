//
//  PastelView.swift
//  Pastel
//
//  Created by Cruz on 05/05/2017.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import UIKit

class PastelView: UIView {

    private struct Animation {
        static let keyPath = "colors"
        static let key = "ColorChange"
    }
    
    //MARK: - Custom Direction

    var startPoint: CGPoint = PastelPoint.topRight.point
    var endPoint: CGPoint = PastelPoint.bottomLeft.point
    
    var startPastelPoint = PastelPoint.topRight {
        didSet {
            startPoint = startPastelPoint.point
        }
    }
    
    var endPastelPoint = PastelPoint.bottomLeft {
        didSet {
            endPoint = endPastelPoint.point
        }
    }
    
    //MARK: - Custom Duration

    var animationDuration: TimeInterval = 5.0
    
    fileprivate let gradient = CAGradientLayer()
    private var currentGradient: Int = 0
    private var colors: [UIColor] = [UIColor(red: 156/255, green: 39/255, blue: 176/255, alpha: 1.0),
                             UIColor(red: 255/255, green: 64/255, blue: 129/255, alpha: 1.0),
                             UIColor(red: 123/255, green: 31/255, blue: 162/255, alpha: 1.0),
                             UIColor(red: 32/255, green: 76/255, blue: 255/255, alpha: 1.0),
                             UIColor(red: 32/255, green: 158/255, blue: 255/255, alpha: 1.0),
                             UIColor(red: 90/255, green: 120/255, blue: 127/255, alpha: 1.0),
                             UIColor(red: 58/255, green: 255/255, blue: 217/255, alpha: 1.0)]
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradient.frame = bounds
    }
    
    func startAnimation() {
        gradient.removeAllAnimations()
        setup()
        animateGradient()
    }
    
    fileprivate func setup() {
        gradient.frame = bounds
        gradient.colors = currentGradientSet()
        gradient.startPoint = startPoint
        gradient.endPoint = endPoint
        gradient.drawsAsynchronously = true
        
        layer.insertSublayer(gradient, at: 0)
    }

    fileprivate func currentGradientSet() -> [CGColor] {
        guard colors.count > 0 else { return [] }
        return [colors[currentGradient % colors.count].cgColor,
                colors[(currentGradient + 1) % colors.count].cgColor]
    }
    
    func setColors(_ colors: [UIColor]) {
        guard colors.count > 0 else { return }
        self.colors = colors
    }
    
    func setPastelGradient(_ gradient: PastelGradient) {
        setColors(gradient.colors())
    }
    
    func addcolor(_ color: UIColor) {
        self.colors.append(color)
    }
    
    func animateGradient() {
        currentGradient += 1
        let animation = CABasicAnimation(keyPath: Animation.keyPath)
        animation.duration = animationDuration
        animation.toValue = currentGradientSet()
        animation.fillMode = .forwards
        animation.isRemovedOnCompletion = false
        animation.delegate = self
        gradient.add(animation, forKey: Animation.key)
    }
    
    override func removeFromSuperview() {
        super.removeFromSuperview()
        gradient.removeAllAnimations()
        gradient.removeFromSuperlayer()
    }
}

extension PastelView: CAAnimationDelegate {
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if flag {
            gradient.colors = currentGradientSet()
            animateGradient()
        }
    }
}
