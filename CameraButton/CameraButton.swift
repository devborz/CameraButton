//
//  CameraButton.swift
//  CameraButton
//
//  Created by Usman Turkaev on 21.01.2022.
//

import UIKit

public protocol CameraButtonDelegate: AnyObject {
    
    func cameraButtonStartedAnimation(_ button: CameraButton)
    
    func cameraButtonEndedAnimation(_ button: CameraButton, animationDuration: Double)
    
    func cameraButtonDidTap(_ button: CameraButton)
}

public class CameraButton: UIView {
    
    enum CameraButtonState {
        case normal, animating
    }
    
    weak var delegate: CameraButtonDelegate?

    private var timer: Timer? {
        didSet {
            time = 0
        }
    }
    
    private var time: Double = 0
    
    private var _state: CameraButtonState = .normal
    
    private var animatingStrokeLayer: CAShapeLayer!
    
    private var defaultStrokeLayer: CAShapeLayer!
    
    private let buttonView = UIView()
    
    private var buttonViewWidthConstraint: NSLayoutConstraint!
    
    // MARK: Public properties
    
    var state: CameraButtonState {
        get {
            return _state
        }
    }
    
    var animationDuration = 15
    
    var buttonBackgroundColor: UIColor = .white {
        didSet {
            buttonView.backgroundColor = buttonBackgroundColor
        }
    }
    
    var defaultStrokeColor: CGColor = UIColor.white.cgColor {
        didSet {
            if state == .normal {
                addDefaultStroke()
            }
        }
    }
    
    var animatingStrokeColor: CGColor = UIColor.systemBlue.cgColor {
        didSet {
            if state == .animating {
                addAnimatingStroke()
            }
        }
    }
    
    var defaultStrokeWidth: CGFloat = 5 {
        didSet {
            if state == .normal {
                addDefaultStroke()
            }
        }
    }
    
    var animatingStrokeWidth: CGFloat = 10 {
        didSet {
            if state == .animating {
                addAnimatingStroke()
            }
        }
    }
    
    var defaultStrokeGapWidth: CGFloat = 5 {
        didSet {
            if state == .normal {
                addDefaultStroke()
            }
        }
    }
    
    var animatingStrokeGapWidth: CGFloat = 10 {
        didSet {
            if state == .animating {
                addAnimatingStroke()
            }
        }
    }
    
    var buttonWidth: CGFloat = 80 {
        didSet {
            buttonViewWidthConstraint.constant = buttonWidth
            buttonView.layer.cornerRadius = buttonWidth / 2
            buttonView.clipsToBounds = true
            buttonView.backgroundColor = buttonBackgroundColor
            if state == .normal {
                addDefaultStroke()
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        backgroundColor = .clear
        
        buttonView.layer.cornerRadius = buttonWidth / 2
        buttonView.clipsToBounds = true
        buttonView.backgroundColor = buttonBackgroundColor
        
        buttonView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(buttonView)
        buttonView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        buttonView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        buttonView.widthAnchor.constraint(equalToConstant: buttonWidth).isActive = true
        buttonView.heightAnchor.constraint(equalTo: buttonView.widthAnchor).isActive = true
        layoutIfNeeded()
        print(buttonView.center)
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleTouches(_:)))
        addGestureRecognizer(longPressGesture)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        addGestureRecognizer(tapGesture)
        addDefaultStroke()
    }
    
    // MARK: Gesture Recognizers
    
    @objc
    func handleTap(_ gesture: UITapGestureRecognizer) {
        delegate?.cameraButtonDidTap(self)
    }

    @objc
    func handleTouches(_ gesture: UILongPressGestureRecognizer) {
        switch gesture.state {
        case .began:
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut) { [weak self] in
                self?.buttonView.alpha = 0.5
                self?.buttonView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            }
            
            timer?.invalidate()
            timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(handleTimer), userInfo: nil, repeats: true)
            
            addAnimatingStroke()
            animateCirleProgress()
            _state = .animating
        case .ended:
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut) { [weak self] in
                self?.stop()
            }
        default:
            break
        }
    }
    
    @objc
    private func handleTimer() {
        time += 0.01
    }
    
    private func stop() {
        if _state == .animating {
            _state = .normal
            animatingStrokeLayer.removeFromSuperlayer()
            addDefaultStroke()
            timer?.invalidate()
            buttonView.alpha = 1
            buttonView.transform = .identity
            
            delegate?.cameraButtonEndedAnimation(self, animationDuration: time)
            time = 0
        }
    }
    
    private func addDefaultStroke() {
        animatingStrokeLayer?.removeFromSuperlayer()
        defaultStrokeLayer?.removeFromSuperlayer()
        let center = buttonView.center
        let circleShapeLayer = CAShapeLayer()
        let circlePath = UIBezierPath(arcCenter: center, radius: buttonWidth / 2 + defaultStrokeGapWidth, startAngle: 0, endAngle: 2 * CGFloat.pi, clockwise: true)
        circleShapeLayer.path = circlePath.cgPath
        circleShapeLayer.strokeColor = defaultStrokeColor
        circleShapeLayer.lineWidth = defaultStrokeWidth
        circleShapeLayer.fillColor = UIColor.clear.cgColor
        circleShapeLayer.lineCap = CAShapeLayerLineCap.round
        circleShapeLayer.strokeEnd = 1
        defaultStrokeLayer = circleShapeLayer
        layer.addSublayer(circleShapeLayer)
    }
    
    private func addAnimatingStroke() {
        animatingStrokeLayer?.removeFromSuperlayer()
        defaultStrokeLayer?.removeFromSuperlayer()
        let center = buttonView.center
        let circleShapeLayer = CAShapeLayer()
        let circlePath = UIBezierPath(arcCenter: center, radius: buttonWidth * 1.2 / 2 + animatingStrokeGapWidth, startAngle: -0.5 * CGFloat.pi, endAngle: 1.5 * CGFloat.pi, clockwise: true)
        circleShapeLayer.path = circlePath.cgPath
        circleShapeLayer.strokeColor = animatingStrokeColor
        circleShapeLayer.lineWidth = animatingStrokeWidth
        circleShapeLayer.fillColor = UIColor.clear.cgColor
        circleShapeLayer.lineCap = CAShapeLayerLineCap.round
        circleShapeLayer.strokeEnd = 0
        animatingStrokeLayer = circleShapeLayer
        layer.addSublayer(circleShapeLayer)
    }

    @objc
    private func animateCirleProgress() {
        let strokeAnimation = CABasicAnimation(keyPath: "strokeEnd")
        strokeAnimation.fromValue = 0
        strokeAnimation.toValue = 1
        strokeAnimation.duration = CFTimeInterval(animationDuration)
        strokeAnimation.fillMode = .forwards
        strokeAnimation.isRemovedOnCompletion = true
        strokeAnimation.delegate = self
        animatingStrokeLayer?.add(strokeAnimation, forKey: "strokeAnimation")
    }
}

extension CameraButton: CAAnimationDelegate {
    public func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if flag {
            stop()
        }
    }
}
