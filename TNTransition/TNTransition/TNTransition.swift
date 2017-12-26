//
//  TNTransition.swift
//  TNTransition
//
//  Created by 涂育旺 on 2017/12/20.
//  Copyright © 2017年 com.person. All rights reserved.
//

import UIKit

//the runtime key
private var typeKey: Void?
private var fromViewKey: Void?
private var toViewKey: Void?
private var transitionContextKey: Void?


//type
enum TNTransitionType {
    case magic(reverse: Bool)
    case page(reverse: Bool)
    case circle(reverse: Bool)
}

public final class TNTransition<Base> {
    public let base: Base
    public init(_ base: Base) {
        self.base = base
    }
}

public protocol TNCompatible {
    associatedtype CompatibleType
    var tn: CompatibleType { get }
}

extension TNCompatible {
    public var tn: TNTransition<Self> { get { return TNTransition(self) } }
}

extension UIViewController: TNCompatible {}

extension TNTransition where Base: UIViewController {
    
    //set delegate
    func setup() {
        guard let navigationController = base.navigationController else { return }
        navigationController.delegate = base
    }
    
    /// setup the transition of viewController
    /// - Parameter type: the viewController transition of type
    /// - Parameter fromView: the animate view of fromViewController
    /// - Parameter toViewKeyPath: the keyPath of toViewController
    func transition(by type: TNTransitionType, from fromView: UIView? = nil, to toViewKeyPath: String? = nil) {
        
        base.tn_type = type
        
        guard fromView != nil else { return }
        base.tn_fromView = fromView!
        
        guard toViewKeyPath != nil else { return }
        base.tn_toViewKeyPath = toViewKeyPath!
    }
    
    //transition by magic
    fileprivate func magic(by: Bool, using: UIViewControllerContextTransitioning) {
        print("magic: " + "\(by)")
        
        if by {
            magicReverse(using: using)
        }else
        {
            magic(using: using)
        }
    }
    
    //transition by page
    fileprivate func page(by: Bool, using: UIViewControllerContextTransitioning) {
        print("page: " + "\(by)")
        if by {
            pageReverse(using: using)
        }else
        {
            page(using: using)
        }
    }
    
    //transition by circle
    fileprivate func circle(by: Bool, using: UIViewControllerContextTransitioning) {
        print("page: " + "\(by)")
         base.tn_transitionContext = using
        if by {
            circleReverse(using: using)
        }else
        {
            circle(using: using)
        }
    }
    
    //magic
    fileprivate func magic(using: UIViewControllerContextTransitioning) {
        guard let toVC = using.viewController(forKey: .to) else { return }
        
        let toView = toVC.value(forKeyPath: base.tn_toViewKeyPath) as! UIView
        let containerView = using.containerView
        guard let snapShotView = base.tn_fromView.snapshotView(afterScreenUpdates: false) else { return }
        snapShotView.frame = containerView.convert(base.tn_fromView.frame, from: base.tn_fromView.superview)
        base.tn_fromView.isHidden = true
        
        toVC.view.frame = using.finalFrame(for: toVC)
        toVC.view.alpha = 0
        toVC.tn_fromView = base.tn_fromView
        toVC.tn_toViewKeyPath = base.tn_toViewKeyPath
        
        toView.isHidden = true
        containerView.addSubview(toVC.view)
        containerView.addSubview(snapShotView)
        
        UIView.animate(withDuration: base.transitionDuration(using: using), delay: 0.0, usingSpringWithDamping: 0.6, initialSpringVelocity: 1.0, options: .curveLinear, animations: {
            containerView.layoutIfNeeded()
            toVC.view.alpha = 1.0
            snapShotView.frame = containerView.convert(toView.frame, from: toView.superview)
            
        }) { (finshed) in
            toView.isHidden = false
            self.base.tn_fromView.isHidden = false
            snapShotView.removeFromSuperview()
            using.completeTransition(!using.transitionWasCancelled)
        }
        
    }
    
    //magic reverse
    fileprivate func magicReverse(using: UIViewControllerContextTransitioning) {
        guard let toVC = using.viewController(forKey: .to) else { return }
        guard let fromVC = using.viewController(forKey: .from) else { return }
        let containerView = using.containerView
        let fromView = fromVC.value(forKeyPath: base.tn_toViewKeyPath) as! UIView
        guard let snapShotView = fromView.snapshotView(afterScreenUpdates: false) else { return }
        snapShotView.frame = containerView.convert(fromView.frame, from: fromView.superview)
        fromView.isHidden = true
        toVC.view.frame = using.finalFrame(for: toVC)
        let originView = fromVC.tn_fromView
        originView.isHidden = true
        containerView.insertSubview(toVC.view, belowSubview: fromVC.view)
        containerView.addSubview(snapShotView)
        
        UIView.animate(withDuration: base.transitionDuration(using: using), delay: 0.0, usingSpringWithDamping: 0.6, initialSpringVelocity: 1.0, options: .curveEaseInOut, animations: {
            fromVC.view.alpha = 0.0
            snapShotView.frame = containerView.convert(originView.frame, from: originView.superview)
        }) { (finished) in
            snapShotView.removeFromSuperview()
            originView.isHidden = false
            using.completeTransition(!using.transitionWasCancelled)
        }
    }
    
    //page
    fileprivate func page(using: UIViewControllerContextTransitioning) {
        guard let fromVC = using.viewController(forKey: .from) else { return }
        guard let toVC = using.viewController(forKey: .to) else { return }
        let containerView = using.containerView
        guard let fromView = fromVC.view else { return }
        guard let toView = toVC.view else { return }
        
        containerView.addSubview(toView)
        containerView.sendSubview(toBack: toView)
        
        var transform = CATransform3DIdentity
        transform.m34 = -0.002
        containerView.layer.sublayerTransform = transform
        
        let initialFrame = using.initialFrame(for: fromVC)
        fromView.frame = initialFrame
        toView.frame = initialFrame
        
        fromView.layer.anchorPoint = CGPoint(x: 0, y: 0.5)
        fromView.layer.position = CGPoint(x: 0, y: UIScreen.main.bounds.midY)
        
        let gradient = CAGradientLayer()
        gradient.frame = fromView.bounds
        gradient.colors = [UIColor(white: 0.0, alpha: 0.5).cgColor,
                           UIColor(white: 0.0, alpha: 0.5).cgColor]
        gradient.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradient.endPoint = CGPoint(x: 0.8, y: 0.5)
        
        let shadow = UIView(frame: fromView.bounds)
        shadow.backgroundColor = .clear
        shadow.layer.insertSublayer(gradient, at: 1)
        shadow.alpha = 0.0
        
        fromView.addSubview(shadow)
        
        UIView.animate(withDuration: base.transitionDuration(using: using), animations: {
            fromView.layer.transform = CATransform3DMakeRotation(-.pi/2, 0.0, 1.0, 0.0)
            shadow.alpha = 1.0
        }) { (finished) in
            fromView.layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            fromView.layer.position = CGPoint(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.midY)
            fromView.layer.transform = CATransform3DIdentity
            shadow.removeFromSuperview()
            using.completeTransition(true)
        }
        
        
    }
    
    //page reverse
    fileprivate func pageReverse(using: UIViewControllerContextTransitioning) {
        guard let fromVC = using.viewController(forKey: .from) else { return }
        guard let toVC = using.viewController(forKey: .to) else { return }
        let containerView = using.containerView
        guard let fromView = fromVC.view else { return }
        guard let toView = toVC.view else { return }
        containerView.addSubview(toView)
        
        var transform = CATransform3DIdentity
        transform.m34 = -0.002
        containerView.layer.sublayerTransform = transform
        
        let initialFrame = using.initialFrame(for: fromVC)
        fromView.frame = initialFrame
        toView.frame = initialFrame
        toView.layer.anchorPoint = CGPoint(x: 0.0, y: 0.5)
        toView.layer.position = CGPoint(x: 0, y: UIScreen.main.bounds.midY)
        toView.layer.transform = CATransform3DMakeRotation(-.pi/2, 0, 1.0, 0)
        
        UIView.animate(withDuration: base.transitionDuration(using: using), animations: {
            toView.layer.transform = CATransform3DMakeRotation(0, 0, 1, 0)
        }) { (finished) in
            toView.layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            toView.layer.position = CGPoint(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.midY)
            using.completeTransition(!using.transitionWasCancelled)
        }
    }
    
    //circle
    fileprivate func circle(using: UIViewControllerContextTransitioning) {
        let containerView = using.containerView
        guard let toVC = using.viewController(forKey: .to) else { return }
        let fromView = base.tn_fromView
        guard let snapShotView = fromView.snapshotView(afterScreenUpdates: false) else { return }
        toVC.tn_fromView = snapShotView
        
        snapShotView.frame = relativeFrame(for: fromView)
        containerView.addSubview(snapShotView)
        containerView.addSubview(toVC.view)
        
        let finalPoint = finalPotint(toVC: toVC, fromView: fromView)
        let radius = sqrt((finalPoint.x * finalPoint.x) + (finalPoint.y * finalPoint.y))
        let maskStartPath = UIBezierPath(ovalIn: snapShotView.frame)
        let maskEndPath = UIBezierPath(ovalIn: snapShotView.frame.insetBy(dx: -radius, dy: -radius))
        let maskLayer = CAShapeLayer()
        maskLayer.path = maskEndPath.cgPath
        toVC.view.layer.mask = maskLayer
        
        let maskAnimation = CABasicAnimation(keyPath: "path")
        maskAnimation.fromValue = maskStartPath.cgPath
        maskAnimation.toValue = maskEndPath.cgPath
        maskAnimation.duration = base.transitionDuration(using: using)
        maskAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        maskAnimation.delegate = base
        maskLayer.add(maskAnimation, forKey: "Circle")
        snapShotView.removeFromSuperview()
    }
    
    //circle reverse
    fileprivate func circleReverse(using: UIViewControllerContextTransitioning) {
        guard let toVC = using.viewController(forKey: .to) else { return }
        guard let fromVC = using.viewController(forKey: .from) else { return }
        let containerView = using.containerView
        let toView = fromVC.tn_fromView
        
        containerView.addSubview(toVC.view)
        containerView.addSubview(fromVC.view)
        let finalPoint = finalPotint(toVC: toVC, fromView: toView)
        let radius = sqrt((finalPoint.x * finalPoint.x) + (finalPoint.y * finalPoint.y))
        let maskStartPath = UIBezierPath(ovalIn: toView.frame.insetBy(dx: -radius, dy: -radius))
        let maskEndPath = UIBezierPath(ovalIn: toView.frame)
        
        let maskLayer = CAShapeLayer()
        maskLayer.path = maskEndPath.cgPath
        fromVC.view.layer.mask = maskLayer
        
        let maskAnimation = CABasicAnimation(keyPath: "path")
        maskAnimation.fromValue = maskStartPath.cgPath
        maskAnimation.toValue = maskEndPath.cgPath
        maskAnimation.duration = base.transitionDuration(using: using)
        maskAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        maskAnimation.delegate = base
        maskLayer.add(maskAnimation, forKey: "CircleInvert")
        
    }
    
    //utility
    fileprivate func relativeFrame(for target: UIView) -> CGRect {
        let screen_height = UIScreen.main.bounds.height
        let screen_width = UIScreen.main.bounds.width
        
        var view = target
        var x: CGFloat = 0.0
        var y: CGFloat = 0.0
        
        while view.frame.width != screen_width || view.frame.height != screen_height {
            x += view.frame.minX
            y += view.frame.minY
            guard let superView = view.superview else { break }
            view = superView
            if view.isKind(of: UIScrollView.self) {
                let scrollView = view as! UIScrollView
                x -= scrollView.contentOffset.x
                y -= scrollView.contentOffset.y
            }
        }
        
        return CGRect(x: x, y: y, width: target.frame.width, height: target.frame.height)
    }
    
    fileprivate func finalPotint(toVC: UIViewController, fromView: UIView) -> CGPoint {
        var finalPoint = CGPoint.zero
        
        if fromView.frame.minX > (toVC.view.bounds.width / 2) {
            if fromView.frame.minY < (toVC.view.bounds.height / 2) {
                finalPoint = CGPoint(x: fromView.center.x - 0, y: fromView.center.y - toVC.view.frame.maxY)
            }else
            {
                finalPoint = CGPoint(x: fromView.center.x - 0, y: fromView.center.y - fromView.center.y - 0)
            }
        }else
        {
            if fromView.frame.minY < (toVC.view.bounds.height / 2) {
                finalPoint = CGPoint(x: fromView.center.x - toVC.view.bounds.maxX, y: fromView.center.y - toVC.view.bounds.maxY)
            }else
            {
                finalPoint = CGPoint(x: fromView.center.x - toVC.view.bounds.maxX, y: fromView.center.y - 0)
            }
        }
        return finalPoint
    }
}

//MARK: UINavigationControllerDelegate
extension UIViewController: UINavigationControllerDelegate {
    
    public func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
}

//MARK: UIViewControllerAnimatedTransitioning
extension UIViewController: UIViewControllerAnimatedTransitioning {
    
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.6
    }
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        switch tn_type {
            
        case .magic(let reverse):
            tn.magic(by: reverse, using: transitionContext)
            break
        case .page(let reverse):
            tn.page(by: reverse, using: transitionContext)
            break
        case .circle(let reverse):
            tn.circle(by: reverse, using: transitionContext)
            break
        }
    }
    
    
}

//MARK: property
extension UIViewController {
    
    //add property by runtime
    fileprivate var tn_type: TNTransitionType {
        set {
            objc_setAssociatedObject(self, &typeKey, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
        
        get{
            return objc_getAssociatedObject(self, &typeKey) as! TNTransitionType
        }
    }
    
    fileprivate var tn_toViewKeyPath: String {
        set {
            objc_setAssociatedObject(self, &toViewKey, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
        
        get{
            return objc_getAssociatedObject(self, &toViewKey) as! String
        }
    }
    
    fileprivate var tn_fromView: UIView {
        set {
            objc_setAssociatedObject(self, &fromViewKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        
        get{
            return objc_getAssociatedObject(self, &fromViewKey) as! UIView
        }
    }
    
    fileprivate var tn_transitionContext: UIViewControllerContextTransitioning {
        set {
            objc_setAssociatedObject(self, &transitionContextKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        
        get {
            return objc_getAssociatedObject(self, &transitionContextKey) as! UIViewControllerContextTransitioning
        }
    }
}

//MARK: CAAnimationDelegate
extension UIViewController: CAAnimationDelegate {
    public func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        
        guard flag else { return }
        
        tn_transitionContext.completeTransition(!tn_transitionContext.transitionWasCancelled)
        tn_transitionContext.viewController(forKey: .from)?.view.layer.mask = nil
        tn_transitionContext.viewController(forKey: .to)?.view.layer.mask = nil
    }
}
