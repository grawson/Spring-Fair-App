//
//  Event.swift
//  Spring Fair
//
//  Created by Gavi Rawson on 12/27/15.
//  Copyright © 2015 Graws Inc. All rights reserved.
//

import Foundation
import SwiftyJSON

class Event {
    
    // Secific event details
    var id: Int
    var name: String
    var location: String
    var startTime: String
    var endTime: String
    var date: String
    var description: String
    
    /**
     Empty initializer.
     
     - returns: Empty event object
     */
    init() {
        self.id = 0
        self.name = ""
        self.location = ""
        self.startTime = ""
        self.endTime = ""
        self.date = ""
        self.description = ""
    }

    /**
     Initialize data for the event.
     
     - parameter data: Event data in JSON format
     
     - returns: Event object
     */
    init(data: JSON) {
        //init all variables
        self.id = data["id"].intValue
        self.name = data["name"].stringValue.capitalizedString
        self.location = data["location"].stringValue
        self.startTime = ""
        self.endTime = ""
        self.date = data["date"].stringValue
        self.description = data["description"].stringValue
        
        //format times
        self.startTime = self.formatTime(data["start_time"].stringValue) ?? ""
        self.endTime = self.formatTime(data["end_time"].stringValue) ?? ""

    }
    
    /**
     Get event ID.
     
     - returns: event ID
     */
    func getID()->Int { return self.id }
    
    /**
     Get event name.
     
     - returns: event name
     */
    func getName()->String { return self.name }
    
    /**
     Get event Location
     
     - returns: Event location
     */
    func getLocation()->String { return self.location }
    
    /**
     Get event starting time in format "h:mm p".
     
     - returns: start time
     */
    func getStartTime()->String { return self.startTime }
    
    /**
     Get event ending time in format "h:mm p".
     
     - returns: event end time
     */
    func getEndTime()->String { return self.endTime }
    
    /**
     Get event date in format "yyyy-mm-dd"
     
     - returns: event date
     */
    func getDate()->String { return self.date }
    
    /**
     Get event description.
     
     - returns: event description
     */
    func getDescription()->String { return self.description }

    /**
     Create an NSDate from the start time and date of an event.
     
     - returns: NSDate of start time and date of event
     */
    func formattedStartNSDate()->NSDate? {
        return self.createNSDate(self.date, time: self.startTime)
    }
    
    /**
     Create an NSDate from the end time and date of an event.
     
     - returns: NSDate of end time and date of event
     */
    func formattedEndNSDate()->NSDate? {
        return self.createNSDate(self.date, time: self.endTime)
    }
    
    /**
     Format the event location to match "location" in database table coordinates.
     All characters become lowercase, and spaces are replaced by "_" character.
     
     - returns: formatted location
     */
    func formattedLocation()->String {
        let lower = self.location.lowercaseString
        return lower.stringByReplacingOccurrencesOfString(
            " ", withString: "_", options: NSStringCompareOptions.LiteralSearch, range: nil
        )
    }
    
    /**
     Convert time string to format "h:mm p"
     
     - parameter time: time to format
     
     - returns: formatted time
     */
    private func formatTime(time: String) -> String? {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        //formatter.timeZone = NSTimeZone(name: "UTC")

        if let formatted = formatter.dateFromString(time) {
            formatter.dateFormat = "h:mm a"
            formatter.AMSymbol = "am"
            formatter.PMSymbol = "pm"
            //formatter.timeZone = NSTimeZone(name: "UTC")
            return formatter.stringFromDate(formatted)
        }
        return nil
    }

    /**
     Create a complete NSDate b combining time and date.
     
     - parameter date: event date
     - parameter time: event time
     
     - returns: comple NSDate
     */
    private func createNSDate(date: String, time: String)->NSDate? {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd hh:mm a"
        let str = date + " " + time
        return formatter.dateFromString(str)
    }

}




