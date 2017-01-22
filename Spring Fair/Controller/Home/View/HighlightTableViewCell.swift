//
//  HighlightTableViewCell.swift
//  Spring Fair
//
//  Created by Gavi Rawson on 12/25/16.
//  Copyright © 2016 Graws Inc. All rights reserved.
//

import UIKit

class HighlightTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var bodyLabel: UILabel!

    var title: String? {
        didSet {
            titleLabel.text = title
        }
    }
    
    var body: String? {
        didSet {
            bodyLabel.text = body
        }
    }

}
