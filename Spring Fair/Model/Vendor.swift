//
//  Vendor.swift
//  Spring Fair
//
//  Created by Gavi Rawson on 12/27/15.
//  Copyright © 2015 Graws Inc. All rights reserved.
//

import Foundation
import SwiftyJSON

class Vendor {
    
    // Vendor data
    fileprivate let id: Int
    fileprivate let name: String
    fileprivate let type: String
    fileprivate let description: String
    let location: String
    var startTime: String
    var endTime: String
    let website: String
    
    /**
     Empty constructor
     
     - returns: Empty vendor object
     */
    init() {
        self.id = 0
        self.name = ""
        self.type = ""
        self.description = ""
        location = ""
        endTime = ""
        startTime = ""
        website = ""
    }
    
    /**
     Initialize vendor details
     
     - parameter data: data containing bendor details in JSON format
     
     - returns: Vendor object
     */
    init(data: JSON) {
        self.id = data["id"].intValue
        self.name = data["name"].stringValue.capitalized
        self.type = data["type"].stringValue
        self.description = data["description"].stringValue
        location = data["location"].stringValue
        startTime = ""
        endTime = ""
        website = data["website"].stringValue
        
        //format times
        self.startTime = self.formatTime(data["start_time"].stringValue) ?? ""
        self.endTime = self.formatTime(data["end_time"].stringValue) ?? ""
    }
    
    /**
     Get the vendor ID
     
     - returns: The vendor ID
     */
    func getID()->Int { return self.id }
    
    /**
     Get the vendor name.
     
     - returns: The vendor name
     */
    func getName()->String { return self.name }
    
    /**
     Get the vendor type
     
     - returns: The vendor type
     */
    func getType()->String { return self.type }
    
    
    /**
     Get the vendor description
     
     - returns: The vendor desciption
     */
    func getDescription()->String { return self.description }
    
    /**
     Format the event location to match "location" in database table coordinates.
     All characters become lowercase, and spaces are replaced by "_" character.
     
     - returns: formatted location
     */
    func formattedLocation()->String {
        let lower = self.location.lowercased()
        return lower.replacingOccurrences(
            of: " ", with: "_", options: NSString.CompareOptions.literal, range: nil
        )
    }
    
    /**
     Convert time string to format "h:mm p"
     
     - parameter time: time to format
     
     - returns: formatted time
     */
    fileprivate func formatTime(_ time: String) -> String? {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        //formatter.timeZone = NSTimeZone(name: "UTC")
        
        if let formatted = formatter.date(from: time) {
            formatter.dateFormat = "h:mm a"
            formatter.amSymbol = "am"
            formatter.pmSymbol = "pm"
            //formatter.timeZone = NSTimeZone(name: "UTC")
            return formatter.string(from: formatted)
        }
        return nil
    }
}
