//
//  Artist.swift
//  Spring Fair
//
//  Created by Gavi Rawson on 3/6/16.
//  Copyright © 2016 Graws Inc. All rights reserved.
//

import Foundation
import SwiftyJSON

class Artist: Event {
    
    var sample: String
    var genre: String
    
    override init() {
        sample = ""
        genre = ""
        super.init()
    }
    
    /**
     Initialize data for the event.
     
     - parameter data: Event data in JSON format
     
     - returns: Event object
     */
    override init(data: JSON) {
        sample = data["sample"].stringValue
        genre = data["genre"].stringValue
        super.init(data: data)
    }
    
}
