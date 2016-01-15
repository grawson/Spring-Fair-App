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
    
    private let defaults = NSUserDefaults.standardUserDefaults()
    
    /// retrive IDs from user defaults
    private var idDict: [String: [Int]] {
        get {
            let ids = defaults.objectForKey(DefaultsKeys.favEvents) as? [Int] ?? []
            return ["ids": ids]
        }
    }
    
    //MARK: - Life cycle
    //********************************************************
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        open.target = self.revealViewController()
        open.action = Selector("revealToggle:")
        
        //opens slide menu with gesture
        self.revealViewController().view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        
        // Needed for disabling user interaction when menu is open
        self.revealViewController().delegate = self
        self.revealViewController().panGestureRecognizer()
        
        self.tableView.delegate = self.tableView
        self.tableView.dataSource = self.tableView

    }
    
    override func viewWillAppear(animated: Bool) {
        self.loadEvents(self.idDict)
    }
    
    //MARK: - Private methods
    //********************************************************
    
    /** 
     Load events from database based on IDs 
     */
    private func loadEvents(ids: [String: [Int]]) {
                
        Alamofire.request(.POST, Requests.eventID, parameters: ids)
            .responseJSON { response in
                
                if let json = response.result.value {
                    self.tableView.events = JSON(json)
                    
                    //if no data, display error message
                    if (self.tableView.events!.isEmpty) {
                        let text = "No favorite events added."
                        self.tableView.errorLabel(text, color: Style.color1)
                    }
                } else {
                    print("Could not load feed")
                    
                    //if no connection, display error message
                    let text = Text.networkFail
                    self.tableView.errorLabel(text, color: Style.color1)
                }
        }
    }
    
    //MARK: - Navigation
    //********************************************************
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            switch identifier {
            case "show event":
                let cell = sender as! UITableViewCell
                if let indexPath = tableView.indexPathForCell(cell) {
                    let destination = segue.destinationViewController as! EventDetailsViewController
                    
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
    func revealController(revealController: SWRevealViewController, willMoveToPosition position: FrontViewPosition){
        self.tableView.userInteractionEnabled = (position == FrontViewPosition.Left)
    }
}



