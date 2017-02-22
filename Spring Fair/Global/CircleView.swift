//
//  CircleView.swift
//
//  Created by Gavi Rawson on 6/18/16.
//  Copyright © 2016 Gavi Rawson. All rights reserved.
//

import UIKit


class CircleView: UIView {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.size.width / 2
        clipsToBounds = true
    }
}
