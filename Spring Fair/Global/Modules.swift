//
//  Modules.swift
//  Spring Fair
//
//  Created by Gavi Rawson on 12/21/15.
//  Copyright © 2015 Graws Inc. All rights reserved.
//

import Foundation
import SwiftyJSON

//MARK: - UIColor extensions
//********************************************************
extension UIColor {
    
    /**
     Create an RGB color from hex value
     
     - parameter red:   red value
     - parameter green: green value
     - parameter blue:  blue value
     
     - returns: The RGB UIColor
     */
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    /**
     Create an RGB color from hex value
     
     - parameter netHex: hex value
     
     - returns: The RGB UIColor
     */
    convenience init(netHex:Int) {
        self.init(red:(netHex >> 16) & 0xff, green:(netHex >> 8) & 0xff, blue:netHex & 0xff)
    }
    
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


//MARK: - UIView extensions
//********************************************************
extension UIView {
    /**
     Round corners of a view
     
     - parameter corners: The corners to round
     - parameter radius:  The rounding radius
     */
    func roundCorners(_ corners:UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
    }
    
    func setCardShadow(opacity:Float=0.05) {
        let layer = self.layer
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 3, height: 3)
        layer.shadowOpacity = opacity
        layer.shadowRadius = 1
    }
}


//MARK: - JSON extensions
//********************************************************
extension JSON {
   
    /**
     Format a timestamp for printing in "h:mm a" format
     
     - parameter date: the unformatted time
     
     - returns: the formatted time
     */
    func formatTime(_ date: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        //formatter.timeZone = NSTimeZone(name: "UTC")
        let date = formatter.date(from: date)
        
        formatter.dateFormat = "h:mm a"
        formatter.amSymbol = "am"
        formatter.pmSymbol = "pm"
        //formatter.timeZone = NSTimeZone(name: "UTC")
        return formatter.string(from: date!)
    }
}


//MARK: - String extensions
//********************************************************
extension String {
    
    /***** MAY NOT WORK - test it ***/

    
     /**
     Convert date from database format to printable date
     
     - parameter date: database formatted date
     
     - returns: formatted date
     */
    func getDay(_ date: String)->String? {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        if let date = formatter.date(from: date) {  //create NSDate object
            //convert string into weekday
            formatter.dateFormat = "EEEE"
            let weekday: String = formatter.string(from: date)
            return weekday
        }
        return nil
    }
}


//MARK: - UITableView extensions
//********************************************************
extension UITableView {
    
    /**
     Present an error label over a table view
     
     - parameter text:  Text for the error label
     - parameter color: Color of the error label text
     */
    func errorLabel(_ text: String, color: UIColor) {
        
        //Add footer view
        let errorView = UIView()
        errorView.backgroundColor = UIColor.white
        errorView.frame = UIApplication.shared.keyWindow?.frame ?? CGRect()
        self.addSubview(errorView)
        self.isScrollEnabled = false
        
        //create label and style
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: errorView.frame.width - 20, height: errorView.frame.height))
        label.center = CGPoint(x: errorView.center.x, y: errorView.center.y / 1.5)
        label.text = text
        label.numberOfLines = 0
        label.textAlignment = .center;
        label.font = (UIFont(name: "Open Sans Condensed", size: 20))
        label.textColor = color

        errorView.addSubview(label)
    }
}


//MARK: - UIButton extensions
//********************************************************
extension UIButton {
    
    /**
     Set the background color for a button
     
     - parameter color:    background color for the button
     - parameter forState: state of the button for which to set the background color
     */
    func setBackgroundColor(_ color: UIColor, forState: UIControlState) {
        UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))
        UIGraphicsGetCurrentContext()?.setFillColor(color.cgColor)
        UIGraphicsGetCurrentContext()?.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
        let colorImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.setBackgroundImage(colorImage, for: forState)
    }
}

extension Date {

    //combine date and time into single nsdate
    static func combineDateWithTime(date: Date?, time: Date?) -> Date? {
        guard let date = date, let time = time else { return nil }
        
        let calendar = NSCalendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: date)
        let timeComponents = calendar.dateComponents([.hour, .minute, .second], from: time)
        
        var merged = DateComponents()
        merged.year = dateComponents.year
        merged.month = dateComponents.month
        merged.day = dateComponents.day
        merged.hour = timeComponents.hour
        merged.minute = timeComponents.minute
        merged.second = timeComponents.second
        return calendar.date(from: merged)

    }

}


