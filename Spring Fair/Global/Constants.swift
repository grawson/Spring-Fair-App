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
    static let lightCream = UIColor(red: 0xff, green: 0xe7, blue: 0xbd)
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
//    static let url = "http://jhuspringfair.com/app_api/"
    static let url = "http://localhost:3300/"
    static let highlights = url + "highlights.php"
    static let allEvents = url + "all_events.php"
    static let allArtists = url + "all_artists.php"
    static let allVendors = url + "all_vendors.php"
    static let eventID = url + "event_id.php"
    static let musicID = url + "music_id.php"
    static let vendorID = url + "vendor_id.php"
    static let coordinates = url + "coordinates.php"
    static let allArtVendors = url + "all_art_vendors.php"
    static let artVendorID = url + "art_vendors_id.php"

}

/**
 *  Keys for NSUser Defaults
 */
struct DefaultsKeys {
    static let favEvents = "EventDetailsViewController.favEvents"
    static let favVendors = "VendorDetailsViewController.favVendors"
    static let favArtists = "VendorDetailsViewController.favArtists"
    static let favArtVendors = "VendorDetailsViewController.favArtVendors"
}

/**
 *  Common strings
 */
struct Text {
    static let networkFail = "No internet connection detected."
    static let accessFailureTitle = "Access Denied"
    static let accessFailureMessage = "Go to Settings > Spring Fair to allow the app to access your calendar."
    static let locationFailureMessage = "Go to Settings > Spring Fair to allow the app to access your location."
}
