//
//  VendorsTableView.swift
//  Spring Fair
//
//  Created by Gavi Rawson on 12/27/15.
//  Copyright © 2015 Graws Inc. All rights reserved.
//

import UIKit
import SwiftyJSON

class VendorsTableView: UITableView {

    //MARK: - Variables
    //********************************************************
    
    var vendors: JSON? {
        didSet { self.reloadData() }
    }
}


// MARK: - Table view data source
//********************************************************
extension VendorsTableView: UITableViewDataSource {
    
    /**
     Number of sections
     */
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    /**
     Number of rows in each section
     */
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.vendors?.count ?? 0
    }
    
    /**
     Row height
     */
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return Style.rowHeight;
    }
    
    /**
     Set up data for each cell
     */
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("vendor", forIndexPath: indexPath) as UITableViewCell
        
        //grab specific vendor
        if let vendor = self.vendors?[indexPath.row] {
            cell.textLabel?.text = vendor["name"].string
            cell.detailTextLabel?.text = vendor["type"].string
            
            cell.textLabel?.font = UIFont(name: "Open Sans Condensed", size: 19)
            cell.detailTextLabel?.font = UIFont(name: "Open Sans Condensed", size: 13)
            
            cell.textLabel?.textColor = Style.darkPurple
            cell.detailTextLabel?.textColor = UIColor.lightGrayColor()
        }
        return cell
    }
}


// MARK: - Table view delegate
//********************************************************
extension VendorsTableView: UITableViewDelegate {
    
    /**
     Deselect row after selection
     */
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)     //deselects cell after segue
    }
}




