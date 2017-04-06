//
//  CheckInEvent.swift
//  Spring Fair
//
//  Created by Gavi Rawson on 4/4/17.
//  Copyright © 2017 Graws Inc. All rights reserved.
//

import Foundation
import SwiftyJSON

class CheckInEvent {
    
    private struct Constants {
        static let timeFormat = "HH:mm:ss"
        static let dateFormat = "yyyy-MM-dd"
    }
    
    var name: String?
    var location: String?
    var date: Date?
    var startTime: Date?
    var endTime: Date?
    
    private var formatter: DateFormatter = {
        let f = DateFormatter()
        return f
    }()
    
    
    init(data: JSON) {
        
        // Str
        name = data["name"].stringValue
        location = data["location"].stringValue
        
        // Date
        formatter.dateFormat = Constants.dateFormat
        let dateStr = data["date"].stringValue
        date = formatter.date(from: dateStr)
        
        // Times
        formatter.dateFormat = Constants.timeFormat
        let startStr = data["start_time"].stringValue
        startTime = formatter.date(from: startStr)
        let endStr = data["end_time"].stringValue
        endTime = formatter.date(from: endStr)
    }
    
    func dateToString() -> String? {
        formatter.dateFormat = "EEEE, MMM d"
        guard let date = date else { return nil }
        return formatter.string(from: date)
    }
    
    func timeToString() -> String? {
        formatter.dateFormat = "h:mm a"
        guard let startTime = startTime,
              let endTime = endTime
        else { return nil }
        return formatter.string(from: startTime) + " - " + formatter.string(from: endTime)

    }
    
    
}
