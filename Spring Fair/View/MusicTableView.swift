//
//  MusicTableView.swift
//  Spring Fair
//
//  Created by Gavi Rawson on 3/5/16.
//  Copyright © 2016 Graws Inc. All rights reserved.
//

import UIKit
import SwiftyJSON

class MusicTableView: UITableView {

    
    //MARK: - Variables
    //********************************************************
    
    var artists: JSON? {
        didSet {
            self.reloadData()
            if artists == nil || artists!.isEmpty {
                errorLabel("No scheduled music.", color: Style.color1)
            }
        }
    }
}


//MARK: - Table view data source
//********************************************************
extension MusicTableView: UITableViewDataSource {
    
    /**
     number of sections in table
     */
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.artists?.count ?? 0
    }
    
    /**
     Create group headers
     */
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        // get data at specific row of json object
        if let event = self.artists?[section][0] {
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
    
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40.0
    }
    
    
    /**
     number of rows in each section
     */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.artists?[section].count ?? 0
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
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "artist", for: indexPath) as UITableViewCell
        
        // get data at specific row of json object
        if let event = self.artists?[indexPath.section][indexPath.row] {
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
extension MusicTableView: UITableViewDelegate {
    
    /**
     Deselect row after selection
     */
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
