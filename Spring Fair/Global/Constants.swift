//
//  Constants.swift
//  Spring Fair
//
//  Created by Gavi Rawson on 12/25/15.
//  Copyright © 2015 Graws Inc. All rights reserved.
//

import Foundation

/**
 *  Styles
 */
struct Style {
    static let color1 = UIColor(red: 0x73, green: 0x71, blue: 0x91)   //greyish purple
    static let lightOrange = UIColor(red: 0xff, green: 0xad, blue: 0x55)
    static let lightBlue = UIColor(red: 117, green: 159, blue: 215)
    static let cream = UIColor(red: 0xff, green: 0xfd, blue: 0xcd)
    static let darkPurple = UIColor(red: 0x44, green: 0x40, blue: 0x55)
    static let rowHeight: CGFloat = 70.0
    static let smallestRounded: CGFloat = 3
    static let smallRounded: CGFloat = 10
    static let largeRounded: CGFloat = 30
    static let zoomImageHeight: CGFloat = 185.0
}

/**
 *  URL Requests
 */
struct Requests {
    static let highlights = "http://jhuspringfair.com/app_api/highlights.php"
    static let allEvents = "http://jhuspringfair.com/app_api/all_events.php"
    static let allVendors = "http://jhuspringfair.com/app_api/all_vendors.php"
    static let eventID = "http://jhuspringfair.com/app_api/event_id.php"
    static let vendorID = "http://jhuspringfair.com/app_api/vendor_id.php"
    static let coordinates = "http://jhuspringfair.com/app_api/coordinates.php"
}

/**
 *  Keys for NSUser Defaults
 */
struct DefaultsKeys {
    static let favEvents = "EventDetailsViewController.favEvents"
    static let favVendors = "VendorDetailsViewController.favVendors"
}

/**
 *  Common strings
 */
struct Text {
    static let networkFail = "No internet connection detected."
    static let accessFailureTitle = "Access Denied"
    static let accessFailureMessage = "Go to Settings > Spring Fair to allow the app to access your calendar."
}
