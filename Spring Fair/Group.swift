//
//  Group.swift
//  Spring Fair
//
//  Created by Gavi Rawson on 4/5/17.
//  Copyright © 2017 Graws Inc. All rights reserved.
//

import Foundation
import SwiftyJSON

class Group {
    
    var name: String?

    init(data: JSON) {
        name = data["name"].stringValue
    }

}
