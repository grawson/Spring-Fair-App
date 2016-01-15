//
//  HighlightsTableViewCell.swift
//  Spring Fair
//
//  Created by Gavi Rawson on 12/25/15.
//  Copyright © 2015 Graws Inc. All rights reserved.
//

import UIKit
import SwiftyJSON

class HighlightsTableViewCell: UITableViewCell {
    
    //MARK: - Outlets
    //********************************************************

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var descript: UITextView!
    
    //MARK: - Variables
    //********************************************************
    
    var data: JSON? {
        didSet {
            self.setup()
        }
    }
    
    //MARK: - Private methods
    //********************************************************
    
    private func setup() {
        title.text = data?["title"].stringValue
        descript.text = data?["description"].stringValue
    }
}




