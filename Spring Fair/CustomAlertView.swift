//
//  CustomAlertView.swift
//  Custom Alert
//
//  Created by Gavi Rawson on 1/10/16.
//  Copyright © 2016 Gavi Rawson. All rights reserved.
//


/** TO DO
 ************
 */


import UIKit


//Animation types for presentation and dismissal
public enum Animation {
    
    /// Present from top, dismiss to bottom
    case flyDown
    
    /// Present from left, dismiss to right
    case flyAcross
}

/**
 *  Delegate protocol.
 */
public protocol CustomAlertDelegate {
    
    /**
     Called when the alert view has been dismissed.
     */
    func alertWasDismissed()
}

open class CustomAlertView: UIView {
    
    /// Delegate
    open var delegate: CustomAlertDelegate?
    
    /// Width of the alert view
    open var frameWidth: CGFloat = 285
    
    /// Height of the content containing the title and the message
    open var contentHeight: CGFloat = 147
    
    /// Space in between the content and the action buttons
    open var offset: CGFloat = 7
    
    /// Height of the action button
    open var actionHeight: CGFloat = 50
    
    /// radius of the rounded corners
    open var rounded: CGFloat = 4
    
    /// Background color of the alert view
    open var viewColor = UIColor(
        red: 0xd1 / 255.0, green: 0xc6 / 255.0,
        blue: 0xff / 255.0, alpha: 1.0
    )
    
    /// Color of the text and exclamation mark
    open var accentColor = UIColor(
        red: 0xd1 / 255.0 - 0.5, green: 0xc6 / 255.0 - 0.5,
        blue: 0xff / 255 - 0.5, alpha: 1.0
    )
    
    /// title for the alert
    open var titleText = "Error"
    
    /// message for the alert
    open var messageText = "Uh oh, we've got an error over here, fix it up and try again."
    
    /// title font
    open var titleFont = "Futura-CondensedExtraBold"
    
    /// Message and button font
    open var messageFont = "Futura"
    
    /// Animation for presentation and dismissal of alert
    open var animation: Animation = .flyDown
    
    /// Container holding alert and dimView
    open var parentView = UIApplication.shared.keyWindow
    
    /// Total height of the alert view frame
    fileprivate var frameHeight: CGFloat {
        return contentHeight + offset + actionHeight
    }
    
    /// View that dims the background behind the alert
    fileprivate var dimView = UIView()
    
    /// Container that holds the alert
    fileprivate var alertView = UIView()
    
    /**
     present (animated) a dimmed background overlay.
     */
    fileprivate func setupDim() {
        //let darkBlur = UIBlurEffect(style: UIBlurEffectStyle.Dark)
        //let dimView = UIVisualEffectView(effect: darkBlur)
        dimView.frame = parentView?.frame ?? CGRect()
        dimView.backgroundColor = UIColor.black
        dimView.alpha = 0
        parentView?.addSubview(dimView)
        
        //animate - fade in
        UIView.animate(withDuration: 0.5, animations: {
            self.dimView.alpha = 0.8
        })
        
    }
    
    /**
     Setup a clear container that holds the alert content and button.
     */
    fileprivate func setupContainer() {
        alertView.frame = CGRect(x: 0, y: 0, width: frameWidth, height: frameHeight)
        alertView.backgroundColor = UIColor.clear
        alertView.center = dimView.center
        parentView?.addSubview(alertView)
    }
    
    /**
     Setup the content view that displays the alert message
     */
    fileprivate func setupContentView() {
        
        //Setup frame for the content view
        var frame = CGRect(x: 0, y: 0, width: frameWidth, height: contentHeight)
        let contentView = UIView(frame: frame)
        contentView.backgroundColor = viewColor
        contentView.roundCorners([.topLeft, .topRight, .bottomRight, .bottomLeft], radius: rounded)
        alertView.addSubview(contentView)
        
        //Draw the circle containing the exclamation mark
        let circlePath = UIBezierPath(
            arcCenter: CGPoint(x: contentView.frame.origin.x + (contentView.frame.width / 2), y: contentView.frame.origin.y),
            radius: 40, startAngle: 0, endAngle: CGFloat(M_PI * 2), clockwise: true
        )
        let layer1 = CAShapeLayer()
        layer1.path = circlePath.cgPath
        layer1.lineWidth = 4
        layer1.strokeColor = viewColor.cgColor
        layer1.fillColor = UIColor.white.cgColor
        layer1.zPosition = 1
        layer1.masksToBounds = false
        alertView.layer.addSublayer(layer1)
        
        //Draw the line for the exclamation mark
        let exLine = UIBezierPath()
        exLine.move(
            to: CGPoint(x: contentView.frame.origin.x + (contentView.frame.width / 2) - 5, y: contentView.frame.origin.y - 24)
        )
        exLine.addLine(
            to: CGPoint(x: contentView.frame.origin.x + (contentView.frame.width / 2) + 5, y: contentView.frame.origin.y - 24)
        )
        exLine.addLine(
            to: CGPoint(x: contentView.frame.origin.x + (contentView.frame.width / 2), y: contentView.frame.origin.y + 10)
        )
        let layer2 = CAShapeLayer()
        layer2.path = exLine.cgPath
        layer2.fillColor = accentColor.cgColor
        layer2.zPosition = 1
        layer1.masksToBounds = false
        alertView.layer.addSublayer(layer2)
        
        //Draw the circle for the exclamation mark
        let exCircle = UIBezierPath(
            arcCenter: CGPoint(x: contentView.frame.origin.x + (contentView.frame.width / 2), y: contentView.frame.origin.y + 20),
            radius: 3, startAngle: 0, endAngle: CGFloat(M_PI * 2), clockwise: true
        )
        let layer3 = CAShapeLayer()
        layer3.path = exCircle.cgPath
        layer3.fillColor = accentColor.cgColor
        layer3.zPosition = 1
        layer1.masksToBounds = false
        alertView.layer.addSublayer(layer3)
        
        //Setup the alert title
        let circleBottomY: CGFloat = contentView.frame.origin.y + 24   //marks the bottom of the circle
        frame = CGRect(
            x: contentView.frame.origin.x + 20, y: circleBottomY + 25,
            width: frameWidth - 40, height: 20
        )
        let title = UILabel(frame: frame)
        title.textColor = accentColor
        title.text = titleText
        title.font = UIFont(name: titleFont, size: 18)
        title.textAlignment = .center
        contentView.addSubview(title)
        
        //setup alert message
        frame = CGRect(
            x: contentView.frame.origin.x + 20, y: title.frame.origin.y + title.frame.height,
            width: frameWidth - 40, height: contentHeight
        )
        let message = UITextView(frame: frame)
        message.backgroundColor = UIColor.clear
        message.isScrollEnabled = false
        message.isEditable = false
        message.text = messageText
        message.font = UIFont(name: messageFont, size: 15)
        message.textColor = accentColor
        message.textAlignment = .center
        contentView.addSubview(message)
    }
    
    /**
     Setup the alert action button.
     */
    fileprivate func setupButton() {
        let frame = CGRect(
            x: bounds.origin.x, y: bounds.origin.y + contentHeight + offset,
            width: frameWidth, height: actionHeight
        )
        let actionButton = UIButton(frame: frame)
        
        //view style
        actionButton.backgroundColor = viewColor
        actionButton.roundCorners([.topLeft, .topRight, .bottomRight, .bottomLeft], radius: rounded)
        
        //text
        actionButton.setTitle("OK", for: UIControlState())
        actionButton.setTitleColor(accentColor, for: UIControlState())
        actionButton.titleLabel?.font = UIFont(name: messageFont, size: 16)
        
        //setup highlighted state for button
        let darkerAccentColor: UIColor = accentColor.adjust(-0.5, green: -0.5, blue: -0.5, alpha: 0)
        actionButton.setBackgroundColor(accentColor, titleColor: darkerAccentColor, forState: .highlighted)
        
        actionButton.addTarget(self, action: #selector(CustomAlertView.dismiss), for: .touchUpInside)
        alertView.addSubview(actionButton)
    }
    
    
    /**
     Dismiss the alert and dim views with animations.
     */
    func dismiss() {
        UIView.animate(withDuration: 0.5,
                       animations: {
                        self.dimView.alpha = 0.0
                        
                        switch self.animation {
                        case .flyAcross: self.alertView.center.x += self.parentView?.frame.width ?? 0  //fly across
                        case.flyDown: self.alertView.center.y += self.parentView?.frame.height ?? 0    //fly down
                        }
                        
        }, completion: {
            (bool) in
            self.dimView.removeFromSuperview()
            self.alertView.removeFromSuperview()
            self.delegate?.alertWasDismissed()
        }
        )
    }
    
    /**
     Recenter the views after an orientation change has occurred.
     */
    func recenter() {
        let windowCenter = parentView?.center ?? CGPoint()
        alertView.center = windowCenter
        dimView.center = windowCenter
        dimView.frame = parentView?.frame ?? CGRect()
    }
    
    /**
     Present the alert view.
     */
    func present() {
        setupDim()
        setupContainer()
        setupContentView()
        setupButton()
        
        //position the alert view based on animation type
        switch self.animation {
        case .flyAcross: alertView.center.x -= parentView?.frame.width ?? 0
        case .flyDown: alertView.center.y -= parentView?.frame.height ?? 0
        }
        
        parentView?.addSubview(alertView)
        UIView.animate(withDuration: 0.5, animations: {
            switch self.animation {
            case .flyAcross: self.alertView.center.x += self.parentView?.frame.width ?? 0
            case .flyDown: self.alertView.center.y += self.parentView?.frame.height ?? 0
            }
        })
    }
}


//MARK: - UIView extensions
//********************************************************
extension UIView {
    
    /**
     Round corners of a view
     
     - parameter corners: The corners to round
     - parameter radius:  The rounding radius
     */
    func roundCorners(_ corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(
            roundedRect: self.bounds, byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
    }
}

//MARK: - UIButton extensions
//********************************************************
extension UIButton {
    
    /**
     Set the background color and title color for a button
     
     - parameter backgroundColor: background color
     - parameter titleColor:      title color
     - parameter forState:        state to set colors
     */
    func setBackgroundColor(_ backgroundColor: UIColor, titleColor: UIColor, forState: UIControlState) {
        UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))
        UIGraphicsGetCurrentContext()?.setFillColor(backgroundColor.cgColor)
        UIGraphicsGetCurrentContext()?.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
        let colorImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.setBackgroundImage(colorImage, for: forState)
        self.setTitleColor(titleColor, for: .highlighted)
    }
}

//MARK: - UIColor extensions
//********************************************************
extension UIColor{
    
    /**
     Adjust an RGB color value.
     
     - parameter red:   red value offset
     - parameter green: green value offset
     - parameter blue:  blue value offset
     - parameter alpha: alpha value offset
     
     - returns: The adjusted color
     */
    func adjust(_ red: CGFloat, green: CGFloat, blue: CGFloat, alpha:CGFloat) -> UIColor{
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        self.getRed(&r, green: &g, blue: &b, alpha: &a)
        return UIColor(red: r+red, green: g+green, blue: b+blue, alpha: a+alpha)
    }
}






