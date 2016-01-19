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
enum Animation {
    
    /// Present from top, dismiss to bottom
    case FlyDown

    /// Present from left, dismiss to right
    case FlyAcross
}

/**
 *  Delegate protocol.
 */
protocol CustomAlertDelegate {
    
    /**
     Called when the alert view has been dismissed.
     */
    func alertWasDismissed()
}

class CustomAlertView: UIView {
    
    /// Delegate
    var delegate: CustomAlertDelegate?
    
    /// Width of the alert view
    var frameWidth: CGFloat = 285
    
    /// Height of the content containing the title and the message
    var contentHeight: CGFloat = 147
    
    /// Space in between the content and the action buttons
    var offset: CGFloat = 7
    
    /// Height of the action button
    var actionHeight: CGFloat = 50
    
    /// radius of the rounded corners
    var rounded: CGFloat = 4

    /// Background color of the alert view
    var viewColor = UIColor(
        red: 0xd1 / 255.0, green: 0xc6 / 255.0,
        blue: 0xff / 255.0, alpha: 1.0
    )
    
    /// Color of the text and exclamation mark
    var accentColor = UIColor(
        red: 0xd1 / 255.0 - 0.5, green: 0xc6 / 255.0 - 0.5,
        blue: 0xff / 255 - 0.5, alpha: 1.0
    )
    
    /// title for the alert
    var titleText = "Error"
    
    /// message for the alert
    var messageText = "Uh oh, we've got an error over here, fix it up and try again."
    
    /// title font
    var titleFont = "Futura-CondensedExtraBold"
    
    /// Message and button font
    var messageFont = "Futura"
    
    /// Animation for presentation and dismissal of alert
    var animation: Animation = .FlyDown
    
    /// Alert view's parent view
    var parentView: UIView?
    
    /// Total height of the alert view frame
    private var frameHeight: CGFloat {
        return contentHeight + offset + actionHeight
    }
    
    /// View that dims the background behind the alert
    private var dimView = UIView()
    
    /**
     present (animated) a dimmed background overlay.
     */
    private func setupDim() {
        //let darkBlur = UIBlurEffect(style: UIBlurEffectStyle.Dark)
        //let dimView = UIVisualEffectView(effect: darkBlur)
        //let dimWindow = UIApplication.sharedApplication().keyWindow
        dimView.frame = parentView?.frame ?? CGRect()
        dimView.backgroundColor = UIColor.blackColor()
        dimView.alpha = 0
        parentView?.addSubview(dimView)
        
        //animate - fade in
        UIView.animateWithDuration(0.5, animations: {
            self.dimView.alpha = 0.6
        })
   
    }
    
    /**
     Setup a clear container that holds the alert content and button.
     */
    private func setupContainer() {
        backgroundColor = UIColor.clearColor()
        center = parentView?.center ?? CGPoint()
    }
    
    /**
     Setup the content view that displays the alert message
     */
    private func setupContentView() {
        
        //Setup frame for the content view
        var frame = CGRect(x: 0, y: 0, width: frameWidth, height: contentHeight)
        let contentView = UIView(frame: frame)
        contentView.backgroundColor = viewColor
        contentView.roundCorners([.TopLeft, .TopRight, .BottomRight, .BottomLeft], radius: rounded)
        addSubview(contentView)
        
        //Draw the circle containing the exclamation mark
        let circlePath = UIBezierPath(
            arcCenter: CGPoint(x: contentView.frame.origin.x + (contentView.frame.width / 2), y: contentView.frame.origin.y),
            radius: 40, startAngle: 0, endAngle: CGFloat(M_PI * 2), clockwise: true
        )
        let layer1 = CAShapeLayer()
        layer1.path = circlePath.CGPath
        layer1.lineWidth = 4
        layer1.strokeColor = viewColor.CGColor
        layer1.fillColor = UIColor.whiteColor().CGColor
        layer1.zPosition = 1
        layer.addSublayer(layer1)
        
        //Draw the line for the exclamation mark
        let exLine = UIBezierPath()
        exLine.moveToPoint(
            CGPoint(x: contentView.frame.origin.x + (contentView.frame.width / 2) - 5, y: contentView.frame.origin.y - 24)
        )
        exLine.addLineToPoint(
            CGPoint(x: contentView.frame.origin.x + (contentView.frame.width / 2) + 5, y: contentView.frame.origin.y - 24)
        )
        exLine.addLineToPoint(
            CGPoint(x: contentView.frame.origin.x + (contentView.frame.width / 2), y: contentView.frame.origin.y + 10)
        )
        let layer2 = CAShapeLayer()
        layer2.path = exLine.CGPath
        layer2.fillColor = accentColor.CGColor
        layer2.zPosition = 1
        layer.addSublayer(layer2)
        
        //Draw the circle for the exclamation mark
        let exCircle = UIBezierPath(
            arcCenter: CGPoint(x: contentView.frame.origin.x + (contentView.frame.width / 2), y: contentView.frame.origin.y + 20),
            radius: 3, startAngle: 0, endAngle: CGFloat(M_PI * 2), clockwise: true
        )
        let layer3 = CAShapeLayer()
        layer3.path = exCircle.CGPath
        layer3.fillColor = accentColor.CGColor
        layer3.zPosition = 1
        layer.addSublayer(layer3)
        
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
        title.textAlignment = .Center
        contentView.addSubview(title)
        
        //setup alert message
        frame = CGRect(
            x: contentView.frame.origin.x + 20, y: title.frame.origin.y + title.frame.height,
            width: frameWidth - 40, height: contentHeight
        )
        let message = UITextView(frame: frame)
        message.backgroundColor = UIColor.clearColor()
        message.scrollEnabled = false
        message.editable = false
        message.text = messageText
        message.font = UIFont(name: messageFont, size: 15)
        message.textColor = accentColor
        message.textAlignment = .Center
        contentView.addSubview(message)
    }
    
    /**
     Setup the alert action button.
     */
    private func setupButton() {
        let frame = CGRect(
            x: bounds.origin.x, y: bounds.origin.y + contentHeight + offset,
            width: frameWidth, height: actionHeight
        )
        let actionButton = UIButton(frame: frame)
       
        //view style
        actionButton.backgroundColor = viewColor
        actionButton.roundCorners([.TopLeft, .TopRight, .BottomRight, .BottomLeft], radius: rounded)
        
        //text
        actionButton.setTitle("OK", forState: .Normal)
        actionButton.setTitleColor(accentColor, forState: .Normal)
        actionButton.titleLabel?.font = UIFont(name: messageFont, size: 16)
        
        //setup highlighted state for button
        let darkerAccentColor: UIColor = accentColor.adjust(-0.5, green: -0.5, blue: -0.5, alpha: 0)
        actionButton.setBackgroundColor(accentColor, titleColor: darkerAccentColor, forState: .Highlighted)
        
        actionButton.addTarget(self, action: "dismiss", forControlEvents: .TouchUpInside)
        addSubview(actionButton)
    }
    
    
    /**
     Dismiss the alert and dim views with animations.
     */
    func dismiss() {
        UIView.animateWithDuration(0.5,
            animations: {
                self.dimView.alpha = 0.0
                
                switch self.animation {
                case .FlyAcross: self.center.x += self.parentView?.frame.width ?? 0  //fly across
                case.FlyDown: self.center.y += self.parentView?.frame.height ?? 0    //fly down
                }
                
            }, completion: {
                (bool) in
                self.dimView.removeFromSuperview()
                self.removeFromSuperview()
                self.delegate?.alertWasDismissed()
            }
        )
    }
    
    /**
     Recenter the views after an orientation change has occurred.
     
     - parameter newView: the new view after rotation\.
     */
    func recenter(newView: UIView) {
        dimView.frame = newView.frame
        center = newView.center
    }
    
    /**
     Present the alert view.
     */
    func present() {
        
        //reset the alert view frame now that variables are initialized
        let frame = CGRect(x: 0, y: 0, width: frameWidth, height: frameHeight)
        self.frame = frame
        
        setupDim()
        setupContainer()
        setupContentView()
        setupButton()
        
        //position the alert view based on animation type
        switch self.animation {
        case .FlyAcross: center.x -= parentView?.frame.width ?? 0
        case .FlyDown: center.y -= parentView?.frame.height ?? 0
        }
        
        parentView?.addSubview(self)
        UIView.animateWithDuration(0.5, animations: {
            switch self.animation {
            case .FlyAcross: self.center.x += self.parentView?.frame.width ?? 0
            case .FlyDown: self.center.y += self.parentView?.frame.height ?? 0
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
    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(
            roundedRect: self.bounds, byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.CGPath
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
    func setBackgroundColor(backgroundColor: UIColor, titleColor: UIColor, forState: UIControlState) {
        UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))
        CGContextSetFillColorWithColor(UIGraphicsGetCurrentContext(), backgroundColor.CGColor)
        CGContextFillRect(UIGraphicsGetCurrentContext(), CGRect(x: 0, y: 0, width: 1, height: 1))
        let colorImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.setBackgroundImage(colorImage, forState: forState)
        self.setTitleColor(titleColor, forState: .Highlighted)
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
    func adjust(red: CGFloat, green: CGFloat, blue: CGFloat, alpha:CGFloat) -> UIColor{
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        self.getRed(&r, green: &g, blue: &b, alpha: &a)
        return UIColor(red: r+red, green: g+green, blue: b+blue, alpha: a+alpha)
    }
}






