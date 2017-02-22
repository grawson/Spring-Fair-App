//
//  HighlightTableViewCell.swift
//  Spring Fair
//
//  Created by Gavi Rawson on 12/25/16.
//  Copyright © 2016 Graws Inc. All rights reserved.
//

import UIKit

class HighlightTableViewCell: UITableViewCell {
    
    var expanded = false {
        didSet {
            bodyLabel.isHidden = !expanded
        }
    }
    
    var highlight: Highlight? {
        didSet {
            titleLabel.text = highlight?.title
            bodyLabel.text = highlight?.body
        }
    }
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var bodyLabel: UILabel! 
    @IBOutlet weak var expandButton: UIButton!
}
