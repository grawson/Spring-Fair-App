//
//  EventsTableView.swift
//  Spring Fair
//
//  Created by Gavi Rawson on 12/27/15.
//  Copyright © 2015 Graws Inc. All rights reserved.
//

import UIKit
import SwiftyJSON

class EventsTableView: UITableView {
    
    //MARK: - Variables
    //********************************************************
    
    var events: JSON? {
        didSet { self.reloadData() }
    }
}


//MARK: - Table view data source
//********************************************************
extension EventsTableView: UITableViewDataSource {
    
    /**
    number of sections in table
    */
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.events?.count ?? 0
    }
    
    /**
     Create group headers
     */
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        // get data at specific row of json object
        if let event = self.events?[section][0] {
            if let date = event["date"].string {
                if let weekday = date.getDay(date) {
                    return weekday
                }
            }
        }
        return nil
    }
    
    /**
     Change color of section headers and text size.
     */
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = Style.lightOrange
        header.textLabel?.font = UIFont(name: "Blenda Script", size: 16)!
        header.textLabel?.text = header.textLabel?.text?.capitalized
    }
    
    /**
     Change height of headers.
     */
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 40.0
    }
    
    /**
     number of rows in each section
     */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.events?[section].count ?? 0
    }
    
    /**
     Row height
     */
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Style.rowHeight;
        
    }
    
    /**
     Set up data for each cell.
     */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "event", for: indexPath) as UITableViewCell
        
        // get data at specific row of json object
        if let event = self.events?[indexPath.section][indexPath.row] {
            cell.textLabel?.text = event["name"].stringValue
            
            var str = event["start_time"].formatTime(event["start_time"].stringValue)
            str += " - " + event["end_time"].formatTime(event["end_time"].stringValue)
            cell.detailTextLabel?.text = str
            
            cell.textLabel?.font = UIFont(name: "Open Sans Condensed", size: 19)
            cell.detailTextLabel?.font = UIFont(name: "Open Sans Condensed", size: 13)
            
            cell.textLabel?.textColor = Style.darkPurple
            cell.detailTextLabel?.textColor = UIColor.lightGray
        }
        return cell
    }
}


//MARK: - Table view delegate
//********************************************************
extension EventsTableView: UITableViewDelegate {
    
    /**
     Deselect row after selection
     */
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}




