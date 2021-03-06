//
//  VendorsTableView.swift
//  Spring Fair
//
//  Created by Gavi Rawson on 12/27/15.
//  Copyright © 2015 Graws Inc. All rights reserved.
//

import UIKit
import SwiftyJSON

class ArtVendorsTableView: UITableView {
    
    //MARK: - Variables
    //********************************************************
    
    var vendors: JSON? {
        didSet {
            self.reloadData()
            if vendors == nil || vendors!.isEmpty {
                errorLabel("No scheduled art vendors.", color: Style.color1)
            }
        }
    }
}


// MARK: - Table view data source
//********************************************************
extension ArtVendorsTableView: UITableViewDataSource {
    
    /**
     Number of sections
     */
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    /**
     Number of rows in each section
     */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.vendors?.count ?? 0
    }
    
    /**
     Row height
     */
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Style.rowHeight;
    }
    
    /**
     Set up data for each cell
     */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "vendor", for: indexPath) as UITableViewCell
        
        //grab specific vendor
        if let vendor = self.vendors?[indexPath.row] {
            cell.textLabel?.text = vendor["name"].string
            cell.detailTextLabel?.text = vendor["type"].string
            
            cell.textLabel?.font = UIFont(name: "Open Sans Condensed", size: 19)
            cell.detailTextLabel?.font = UIFont(name: "Open Sans Condensed", size: 13)
            
            cell.textLabel?.textColor = Style.darkPurple
            cell.detailTextLabel?.textColor = UIColor.lightGray
        }
        return cell
    }
}


// MARK: - Table view delegate
//********************************************************
extension ArtVendorsTableView: UITableViewDelegate {
    
    /**
     Deselect row after selection
     */
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)     //deselects cell after segue
    }
}




