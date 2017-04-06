//
//  FavoriteEventsViewController.swift
//  Spring Fair
//
//  Created by Gavi Rawson on 12/27/15.
//  Copyright © 2015 Graws Inc. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class FavoriteEventsViewController: UIViewController {

    //MARK: - Outlets
    //********************************************************
    
    @IBOutlet weak var open: UIBarButtonItem!
    @IBOutlet weak var tableView: EventsTableView!
    
    //MARK: - Variables
    //********************************************************
    
    fileprivate let defaults = UserDefaults.standard
    
    /// retrive IDs from user defaults
    fileprivate var idDict: [String: String] {
        get {
            let ids = defaults.object(forKey: DefaultsKeys.favEvents) as? [Int] ?? []
            return ["ids": "\(ids)"]
        }
    }
    
    //MARK: - Life cycle
    //********************************************************
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        open.target = self.revealViewController()
        open.action = #selector(SWRevealViewController.revealToggle(_:))
        
        //opens slide menu with gesture
        self.revealViewController().view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        
        // Needed for disabling user interaction when menu is open
        self.revealViewController().delegate = self
        self.revealViewController().panGestureRecognizer()
        
        self.tableView.delegate = self.tableView
        self.tableView.dataSource = self.tableView

    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false //show tab bar
        self.loadEvents(self.idDict)
    }
    
    
    //MARK: - Private methods
    //********************************************************
    
    /** 
     Load events from database based on IDs 
     */
    fileprivate func loadEvents(_ ids: [String: String]) {
        
        if Reachability.isConnectedToNetwork() {
            Alamofire.request(Requests.eventID, method: .post, parameters: ids)
                .responseJSON { response in
                    
                    if let json = response.result.value {
                        self.tableView.events = JSON(json)
                        
                        //if no data, display error message
                        if (self.tableView.events!.isEmpty) {
                            let text = "No favorite events added."
                            self.tableView.errorLabel(text, color: Style.color1)
                        }
                    } else {
                        let text = "No favorite events added."
                        self.tableView.errorLabel(text, color: Style.color1)
                    }
            }
        } else {
            tableView.events = nil
            tableView.reloadData()
            self.tableView.errorLabel(Text.networkFail, color: Style.color1)
        }
    
    }
    
    //MARK: - Navigation
    //********************************************************
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            switch identifier {
            case "show event":
                let cell = sender as! UITableViewCell
                if let indexPath = tableView.indexPath(for: cell) {
                    let destination = segue.destination as! EventDetailsViewController
                    
                    // get data at specific row of json object
                    if let event = self.tableView.events?[indexPath.section][indexPath.row] {
                        destination.event = Event(data: event)
                    }
                    
                }
            default: break
                
            }
        }
    }
}

//MARK: - SW Reveal controller delegate
//********************************************************
extension FavoriteEventsViewController: SWRevealViewControllerDelegate {
    
    /**
     Needed for disabling user interaction when menu is open
     */
    func revealController(_ revealController: SWRevealViewController, willMoveTo position: FrontViewPosition){
        self.tableView.isUserInteractionEnabled = (position == FrontViewPosition.left)
    }
}



