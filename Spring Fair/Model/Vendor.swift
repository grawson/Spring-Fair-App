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
    private let id: Int
    private let name: String
    private let type: String
    private let description: String
    
    /**
     Empty constructor
     
     - returns: Empty vendor object
     */
    init() {
        self.id = 0
        self.name = ""
        self.type = ""
        self.description = ""
    }
    
    /**
     Initialize vendor details
     
     - parameter data: data containing bendor details in JSON format
     
     - returns: Vendor object
     */
    init(data: JSON) {
        self.id = data["id"].intValue
        self.name = data["name"].stringValue.capitalizedString
        self.type = data["type"].stringValue
        self.description = data["description"].stringValue
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
}
