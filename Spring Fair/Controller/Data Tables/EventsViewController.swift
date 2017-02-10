//
//  EventsViewController.swift
//  Spring Fair
//
//  Created by Gavi Rawson on 12/27/15.
//  Copyright © 2015 Graws Inc. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Cache
////import AlamofireSpinner

class EventsViewController: UIViewController {
    
    //MARK: - Outlets
    //********************************************************
    
    @IBOutlet weak var open: UIBarButtonItem!
    @IBOutlet weak var tableView: EventsTableView!
    
    //MARK: - Life Cycle
    //********************************************************
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //bar button
        open.target = self.revealViewController()
        open.action = #selector(SWRevealViewController.revealToggle(_:))
        
        //opens slide menu with gesture
        self.revealViewController().view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        
        // Needed for disabling user interaction when menu is open */
        self.revealViewController().delegate = self
        self.revealViewController().panGestureRecognizer()
        
        self.tableView.delegate = self.tableView
        self.tableView.dataSource = self.tableView
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.loadEvents()
    }
    
    //MARK: - Private methods
    //********************************************************
    
    /** Load all events from database. */
    fileprivate func loadEvents() {
        
        guard Reachability.isConnectedToNetwork() else {
            tableView.events = nil
            tableView.reloadData()
            tableView.errorLabel(Text.networkFail, color: Style.color1)
            return
        }
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        Alamofire.request(Requests.allEvents, method: .get).responseJSON { [weak self] response in
                
            guard let strongSelf = self else { return }
            
            // data result found
            if let json = response.result.value {
                let data = JSON(json)
                DispatchQueue.main.async {
                    strongSelf.tableView.events = data
                }
            }

            // stop spinner
            DispatchQueue.main.async {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
    }
    
    
    //MARK: - Navigation
    //********************************************************
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            switch identifier {
            case "show event":
                let cell = sender as! UITableViewCell
                if let indexPath = self.tableView.indexPath(for: cell) {
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

//MARK: - SWReveal controller delegate
//********************************************************
extension EventsViewController: SWRevealViewControllerDelegate {
    
    /**
     Needed for disabling user interaction when menu is open
     */
    func revealController(_ revealController: SWRevealViewController, willMoveTo position: FrontViewPosition){
        self.tableView.isUserInteractionEnabled = (position == FrontViewPosition.left)
    }
}


