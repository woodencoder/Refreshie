//
//  Refreshie.swift
//  Refreshie
//
//  Created by vladislav klimenko on 02/03/2018.
//  Copyright © 2018 Wooden Co. All rights reserved.
//

import UIKit

extension UIView {
    public static let kRotationAnimationKey = "rotationAnimation"
    public static let kProgressAnimationKey = "progressAnimation"
}


public class Refreshie: UIView {
    
    public var radius: CGFloat = 15
    public var fillColor: UIColor = .red
    public var innerCircleColor: UIColor = .blue
    public var circleWidth: CGFloat = 2.0
    public var requiredDraggingOffset: CGFloat = 100.0
    public var hideAnimationDuration: TimeInterval = 1.0
    
    public private(set) var isRefreshing: Bool = false
    
    public var onRefreshAction: (() -> Void)?
    
    private var constraintToParent: NSLayoutConstraint?
    private var circleLayer: CAShapeLayer = CAShapeLayer()
    
    private var counterForceCoefficent: CGFloat = 1.0
    private var counterForceIncrement: CGFloat = 1.5
    
    private var bounceAnimationSpringDumping: CGFloat = 0.5
    private var bounceAnimationSpringVelocity: CGFloat = 0.5
    private var bounceAnimationDuration: TimeInterval = 0.7
    
    private var hideAnimationSpingDumping: CGFloat = 0.7
    private var hideAnimationSpringVelocity: CGFloat = 0.0
    
    // MARK: - Public methods

    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        translatesAutoresizingMaskIntoConstraints = false
        setupBasicAppearance()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func add(to view: UIView) {
        view.addSubview(self)
        
        setupBasicAppearance()
        
        createSizeConstraints()
        createConstraints(to: view)
        
        
        setupPanRecognizer(for: view)
        
        
        setupCircleLayer()
    }
    
    public func endRefreshing() {
        isRefreshing = false
        
        stopRotating()
        animateCircle(to: 0.0)
        
        constraintToParent?.constant = -bounds.height
        UIView.animate(withDuration: hideAnimationDuration,
                       delay: 0,
                       usingSpringWithDamping: 0.7,
                       initialSpringVelocity: 0.0,
                       options: [],
                       animations: {
                        self.superview?.layoutIfNeeded()
        }, completion: nil)
    }
    
    public func beginRefreshing() {
        isRefreshing = true
        
        onRefreshAction?()
        
        circleLayer.strokeEnd = 0.5
        startRotating()
    }
    
    // MARK: - Private methods
    
    private func setupBasicAppearance() {
        self.backgroundColor = fillColor
        self.layer.cornerRadius = radius
    }
    
    private func setupCircleLayer() {
        let arcCenter = CGPoint(x: frame.size.width / 2,
                                y: frame.size.height / 2)
        let circlePath = UIBezierPath(arcCenter: arcCenter,
                                      radius: radius - circleWidth,
                                      startAngle: -.pi / 2,
                                      endAngle: .pi * 2,
                                      clockwise: true)
        
        circleLayer.path = circlePath.cgPath
        circleLayer.fillColor = UIColor.clear.cgColor
        circleLayer.strokeColor = innerCircleColor.cgColor
        circleLayer.lineWidth = circleWidth
        
        circleLayer.strokeEnd = 0.0
        
        layer.addSublayer(circleLayer)
    }
    
    private func createConstraints(to view: UIView) {
        let topConstraint = NSLayoutConstraint(item: self,
                                               attribute: .top,
                                               relatedBy: .equal,
                                               toItem: view,
                                               attribute: .top,
                                               multiplier: 1.0,
                                               constant: -bounds.height)
        let centerConstraint = NSLayoutConstraint(item: self,
                                                  attribute: .centerX,
                                                  relatedBy: .equal,
                                                  toItem: view,
                                                  attribute: .centerX,
                                                  multiplier: 1.0,
                                                  constant: 0.0)
        self.constraintToParent = topConstraint
        view.addConstraints([topConstraint, centerConstraint])
        self.layoutIfNeeded()
    }
    
    private func createSizeConstraints() {
        let heightConstraint = NSLayoutConstraint(item: self,
                                                  attribute: .height,
                                                  relatedBy: .equal,
                                                  toItem: nil,
                                                  attribute: .notAnAttribute,
                                                  multiplier: 0.0,
                                                  constant: radius * 2)
        let widthConstraint = NSLayoutConstraint(item: self,
                                                 attribute: .width,
                                                 relatedBy: .equal,
                                                 toItem: self,
                                                 attribute: .height,
                                                 multiplier: 1.0,
                                                 constant: 0.0)
        self.addConstraints([heightConstraint, widthConstraint])
        self.layoutIfNeeded()
    }
    
    private func setupPanRecognizer(for view: UIView) {
        let panGestureRecognizer = UIPanGestureRecognizer(target: self,
                                                          action: #selector(handleDraggingEvent(_:)))
        
        view.addGestureRecognizer(panGestureRecognizer)
    }
    
    
    
    @objc private func handleDraggingEvent(_ sender: UIPanGestureRecognizer) {
        guard let constraintToParent = constraintToParent else { return }
        
        let translation = sender.translation(in: superview)
        
        switch sender.state {
        case .changed:
            guard !self.isRefreshing else { return }
            
            let deltaTranslation = translation.y - constraintToParent.constant
            
            if translation.y > requiredDraggingOffset {
                self.counterForceCoefficent += counterForceIncrement
            } else {
                if counterForceCoefficent - counterForceIncrement <= 1.0 {
                    self.counterForceCoefficent = 1.0
                } else {
                    self.counterForceCoefficent -= counterForceIncrement
                }
                
            }
            
            let progress = translation.y / requiredDraggingOffset
            
            circleLayer.strokeEnd = progress
            
            constraintToParent.constant += deltaTranslation / counterForceCoefficent
            superview?.layoutIfNeeded()
        case .ended:
            if translation.y > requiredDraggingOffset {
                bounce(to: requiredDraggingOffset)
                beginRefreshing()
            } else {
                endRefreshing()
            }
            counterForceCoefficent = 1.0
        default:
            break
        }
    }
    
    
    
    private func animateCircle(to progress: CGFloat) {
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        
        animation.duration = hideAnimationDuration / 2
        animation.fromValue = circleLayer.strokeEnd
        animation.toValue = progress
        
        circleLayer.strokeEnd = 0.0
        
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        
        circleLayer.add(animation, forKey: UIView.kProgressAnimationKey)
    }
    
    private func bounce(to offset: CGFloat) {
        
        constraintToParent?.constant = offset
        UIView.animate(withDuration: bounceAnimationDuration,
                       delay: 0.0,
                       usingSpringWithDamping: bounceAnimationSpringDumping,
                       initialSpringVelocity: bounceAnimationSpringVelocity,
                       options: [],
                       animations: {
                        self.superview?.layoutIfNeeded()
        }, completion: nil)
        
        
    }
    
    private func startRotating() {
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        
        rotationAnimation.fromValue = 0.0
        rotationAnimation.toValue = Float.pi * 2
        rotationAnimation.duration = 1.0
        rotationAnimation.repeatCount = .infinity
        
        self.layer.add(rotationAnimation, forKey: UIView.kRotationAnimationKey)
    }
    
    
    private func stopRotating() {
        guard layer.animation(forKey: UIView.kRotationAnimationKey) != nil else { return }
        layer.removeAnimation(forKey: UIView.kRotationAnimationKey)
    }
    
}
