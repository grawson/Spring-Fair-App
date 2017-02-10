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
    
    struct Keys {
        static let Title = "title"
        static let Likes = "likes"
        static let Body = "description"
    }
    
    var title: String?
    var likes: Int?
    var body: String?
    
    var description: String {
        return "Title: \(title)\n"
                + "Body: \(body)\n"
                + "Likes: \(likes)\n"
    }
    
    init(data: JSON) {
        title = data[Keys.Title].string
        likes = data[Keys.Likes].int
        body = data[Keys.Body].string
    }
    
    
}
