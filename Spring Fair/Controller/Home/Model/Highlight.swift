//
//  Highlight.swift
//  Spring Fair
//
//  Created by Gavi Rawson on 12/24/16.
//  Copyright © 2016 Graws Inc. All rights reserved.
//

import Foundation
import SwiftyJSON

class Highlight: CustomStringConvertible {
    
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter
    }()
    
    struct Keys {
        static let title = "title"
        static let date = "date"
        static let body = "description"
    }
    
    var title: String?
    var body: String?
    var date: Date?
    
    var description: String {
        return "Title: \(title)\n"
                + "Body: \(body)\n"
    }
    
    init(data: JSON) {
        title = data[Keys.title].string
        body = data[Keys.body].string
        
        // convert datetime to Date
        let dateString = data[Keys.date].string ?? ""
        date = dateFormatter.date(from: dateString)
    }
    
    
}
