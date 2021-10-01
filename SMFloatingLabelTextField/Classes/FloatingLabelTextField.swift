//
//  FloatingLabelTextField.swift
//  SMFloatingLabelTextField
//
//  Created by Miroslaw Stanek on 01/10/2021.
//

import Foundation
import UIKit

public class FloatingLabelTextField: UITextField {
    
    @IBInspectable public var floatingLabelActiveColor = UIColor.lightGray {
        didSet {
            if self.displayFloatingPlaceholder {
                self.floatingLabel.textColor = floatingLabelActiveColor
            }
        }
    }
    
    @IBInspectable public var floatingLabelPassiveColor = UIColor.lightGray {
        didSet {
            if !self.displayFloatingPlaceholder {
                self.floatingLabel.textColor = floatingLabelPassiveColor
            }
        }
    }
    
    @IBInspectable public var floatingLabelLeadingOffset = 0.0 {
        didSet {
            if let floatingLabelLeadingConstraint = self.floatingLabelLeadingConstraint {
                floatingLabelLeadingConstraint.constant = floatingLabelLeadingOffset
                layoutIfNeeded()
            }
        }
    }
    
    @IBInspectable public var floatingLabelFont = UIFont.systemFont(ofSize: 12.0) {
        didSet {
            self.floatingLabel.font = floatingLabelFont
        }
    }
    
    private var floatingLabel: UILabel!
    private var floatingLabelTopSpaceConstraint: NSLayoutConstraint?
    private var floatingLabelLeadingConstraint: NSLayoutConstraint?
    private var displayFloatingPlaceholder: Bool = false
    private var layoutLabelWhenThereIsNoText: Bool = false
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setup()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    func setup() {
        self.floatingLabelLeadingOffset = self.textRect(forBounds: self.bounds).origin.x
        self.setupFloatingLabel()
        self.setupObservers()
    }
    
    func setupFloatingLabel() {
        let floatingLabel = UILabel.init(frame: CGRect.zero)
        floatingLabel.translatesAutoresizingMaskIntoConstraints = false
        floatingLabel.text = self.placeholder
        floatingLabel.alpha = 0.0
        floatingLabel.font = self.floatingLabelFont
        floatingLabel.textColor = self.floatingLabelPassiveColor
        
        self.floatingLabel = floatingLabel
        self.insertSubview(self.floatingLabel, at: 0)
        
        let floatingLabelLeadingConstraint = NSLayoutConstraint.init(
            item: floatingLabel,
            attribute: NSLayoutConstraint.Attribute.leading,
            relatedBy: NSLayoutConstraint.Relation.equal,
            toItem: self,
            attribute: NSLayoutConstraint.Attribute.leading,
            multiplier: 1.0,
            constant: self.floatingLabelLeadingOffset)
        self.floatingLabelLeadingConstraint = floatingLabelLeadingConstraint
        
        let floatingLabelTopSpaceConstraint = NSLayoutConstraint.init(
            item: floatingLabel,
            attribute: NSLayoutConstraint.Attribute.top,
            relatedBy: NSLayoutConstraint.Relation.equal,
            toItem: self,
            attribute: NSLayoutConstraint.Attribute.top,
            multiplier: 1.0,
            constant: 0.0)
        self.floatingLabelTopSpaceConstraint = floatingLabelTopSpaceConstraint
        self.addConstraints([floatingLabelLeadingConstraint,
                             floatingLabelTopSpaceConstraint])
    }
    
    func setupObservers() {
        self.addTarget(self, action: #selector(textFieldBeginEditing), for: UIControl.Event.editingDidBegin)
        self.addTarget(self, action: #selector(textFieldEndEditing), for: UIControl.Event.editingDidEnd)
        self.addTarget(self, action: #selector(textDidChangeInteractively), for: UIControl.Event.editingChanged)
        self.addObserver(self, forKeyPath: "text", options: NSKeyValueObservingOptions.new, context: nil)
    }
    
    // MARK: observing changes
    
    public override func observeValue(forKeyPath keyPath: String?,
                                      of object: Any?,
                                      change: [NSKeyValueChangeKey : Any]?,
                                      context: UnsafeMutableRawPointer?) {
        if keyPath == "text" {
            self.textDidChangeProgramatically()
            self.layoutLabelWhenThereIsNoText = true
        }
    }
    
    @objc func textFieldBeginEditing() {
        self.floatingLabel.textColor = self.floatingLabelActiveColor
    }
    
    @objc func textFieldEndEditing() {
        self.floatingLabel.textColor = self.floatingLabelPassiveColor
    }
    
    @objc func textDidChangeInteractively() {
        self.handleFloatingLabelStateForCurrentTextAnimated(true)
    }

    func textDidChangeProgramatically() {
        self.handleFloatingLabelStateForCurrentTextAnimated(false)
    }
    
    func handleFloatingLabelStateForCurrentTextAnimated(_ animated: Bool) {
        if let text = self.text, !text.isEmpty {
            self.displayFloatingPlaceholder = true
            self.layoutFloatingLabelPositionAndAlpha(1.0, animated:animated)
        } else {
            if (self.layoutLabelWhenThereIsNoText) {
                self.layoutIfNeeded()
                self.layoutLabelWhenThereIsNoText = false
            }
            self.displayFloatingPlaceholder = false
            self.layoutFloatingLabelPositionAndAlpha(0.0, animated:animated)
        }
    }
    
    func layoutFloatingLabelPositionAndAlpha(_ alpha: CGFloat, animated: Bool) {
        self.updateConstraintsToCurrentState()
        
        if animated {
            UIView.animate(withDuration: 0.2,
                           delay: 0.0,
                           options: UIView.AnimationOptions.curveEaseIn) {
                self.floatingLabel.alpha = alpha
                self.layoutIfNeeded()
            }
        } else {
            self.floatingLabel.alpha = alpha
            self.layoutIfNeeded()
        }
    }
    
    func updateConstraintsToCurrentState() {
        if self.displayFloatingPlaceholder {
            floatingLabelTopSpaceConstraint!.constant = 0.0;
        } else {
            floatingLabelTopSpaceConstraint!.constant = self.bounds.midY - self.floatingLabel.bounds.midY;
        }
    }
    
    // MARK: overriden method
    
    public override var placeholder: String? {
        didSet {
            self.floatingLabel.text = placeholder
        }
    }
    
    public override var attributedPlaceholder: NSAttributedString? {
        didSet {
            self.floatingLabel.attributedText = self.floatingLabelAttributedPlacecholderStringFrom(attributedPlaceholder)
        }
    }
    
    func floatingLabelAttributedPlacecholderStringFrom(_ attributedString: NSAttributedString?) -> NSAttributedString? {
        guard let attributedString = attributedString else { return nil }
        
        let mutableAttributedStr = NSMutableAttributedString(attributedString: attributedString)
        let fullRange = mutableAttributedStr.string.range(of: mutableAttributedStr.string)!
        let fullRangeCompat = NSRange(fullRange, in: mutableAttributedStr.string)
        mutableAttributedStr.removeAttribute(NSAttributedString.Key.font, range: fullRangeCompat)
        mutableAttributedStr.removeAttribute(NSAttributedString.Key.foregroundColor, range: fullRangeCompat)
        
        mutableAttributedStr.addAttribute(NSAttributedString.Key.font, value: self.floatingLabelFont, range: fullRangeCompat)
        
        if self.displayFloatingPlaceholder {
            mutableAttributedStr.addAttribute(NSAttributedString.Key.foregroundColor, value: self.floatingLabelActiveColor, range: fullRangeCompat)
        } else {
            mutableAttributedStr.addAttribute(NSAttributedString.Key.foregroundColor, value: self.floatingLabelPassiveColor, range: fullRangeCompat)
        }
        
        return mutableAttributedStr
    }
}
