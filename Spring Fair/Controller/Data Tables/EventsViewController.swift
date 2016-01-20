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
        open.action = Selector("revealToggle:")
        
        //opens slide menu with gesture
        self.revealViewController().view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        
        // Needed for disabling user interaction when menu is open */
        self.revealViewController().delegate = self
        self.revealViewController().panGestureRecognizer()
        
        self.tableView.delegate = self.tableView
        self.tableView.dataSource = self.tableView
        
    }
    
    override func viewWillAppear(animated: Bool) {
        self.loadEvents()
    }
    
    //MARK: - Private methods
    //********************************************************
    
    /** Load events from database based on IDs */
    private func loadEvents() {

        let mutableURLRequest = NSMutableURLRequest(URL: NSURL(string: Requests.allEvents)!)
        mutableURLRequest.HTTPMethod = Method.POST.rawValue
        let encodedURLRequest = ParameterEncoding.JSON.encode(mutableURLRequest, parameters: ["": ""]).0
        let data = encodedURLRequest.HTTPBody!
        
        
        Alamofire.upload(mutableURLRequest, data: data)
            .progress { _, totalBytesRead, totalBytesExpectedToRead in
                UIApplication.sharedApplication().networkActivityIndicatorVisible = true
            }
            .responseJSON { response in
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                
                if let json = response.result.value {
                    self.tableView.events = JSON(json)
                    
                    //if no data, display error message
                    if (self.tableView.events!.isEmpty) {
                        let text = "No scheduled events."
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
        print("here")
        if let identifier = segue.identifier {
            switch identifier {
            case "show event":
                let cell = sender as! UITableViewCell
                if let indexPath = self.tableView.indexPathForCell(cell) {
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

//MARK: - SWReveal controller delegate
//********************************************************
extension EventsViewController: SWRevealViewControllerDelegate {
    
    /**
     Needed for disabling user interaction when menu is open
     */
    func revealController(revealController: SWRevealViewController, willMoveToPosition position: FrontViewPosition){
        self.tableView.userInteractionEnabled = (position == FrontViewPosition.Left)
    }
}


