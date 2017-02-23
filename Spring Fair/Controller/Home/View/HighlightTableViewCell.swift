//
//  HighlightTableViewCell.swift
//  Spring Fair
//
//  Created by Gavi Rawson on 12/25/16.
//  Copyright © 2016 Graws Inc. All rights reserved.
//

import UIKit

class HighlightTableViewCell: UITableViewCell {
    
    struct Const {
        static let upArrow = "up-arrow"
        static let downArrow = "down-arrow"
    }
    
    var expanded = false {
        didSet {
            bodyLabel.isHidden = !expanded
            expandedSpacer.isHidden = !expanded
            arrowImage.image = expanded ? UIImage(named: Const.upArrow) : UIImage(named: Const.downArrow)
        }
    }
    
    var highlight: Highlight? {
        didSet {
            titleLabel.text = highlight?.title
            bodyLabel.text = highlight?.body
            
            if let postDate = highlight?.date {
                let flags: Set<Calendar.Component> = [.day, .hour, .minute, .second]
                let diff = Calendar.current.dateComponents(flags, from: Date(), to: postDate)
                
                if let days = diff.day, abs(days) > 0 {
                    let val = abs(days)
                    postDateLabel.text = val == 1 ? "\(val) day" : "\(val) days"
                } else if let hrs = diff.hour, abs(hrs) > 0 {
                    let val = abs(hrs)
                    postDateLabel.text = val == 1 ? "\(val) hr" : "\(val) hrs"
                } else if let mins = diff.minute, abs(mins) > 0 {
                    let val = abs(mins)
                    postDateLabel.text = val == 1 ? "\(val) min" : "\(val) mins"
                } else if let sec = diff.second, abs(sec) > 0 {
                    let val = abs(sec)
                    postDateLabel.text = val == 1 ? "\(val) sec" : "\(val) secs"

                }
            }
            
        }
    }
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var bodyLabel: UILabel! 
    @IBOutlet weak var expandButton: UIButton!
    @IBOutlet weak var postDateLabel: UILabel!
    @IBOutlet weak var arrowImage: UIImageView!
    @IBOutlet weak var expandedSpacer: UIView!
}
