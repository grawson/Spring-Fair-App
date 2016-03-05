//
//  MusicViewController.swift
//  Spring Fair
//
//  Created by Gavi Rawson on 3/5/16.
//  Copyright © 2016 Graws Inc. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class MusicViewController: UIViewController {

    //MARK: - Outlets
    //********************************************************
    
    @IBOutlet weak var menu: UIBarButtonItem!
    @IBOutlet weak var tableView: MusicTableView!
    
    
    //MARK: - Life Cycle
    //********************************************************
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //bar button
        self.menu.target = self.revealViewController()
        self.menu.action = Selector("revealToggle:")
        
        //opens slide menu with gesture
        self.revealViewController().view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        
        // Disable user interaction when menu is open
        self.revealViewController().delegate = self
        self.revealViewController().panGestureRecognizer()
        
        self.tableView.delegate = self.tableView
        self.tableView.dataSource = self.tableView
        
        style()
    }
    
    override func viewWillAppear(animated: Bool) {
        self.loadArtists()
    }
    
    //MARK: - Private methods
    //********************************************************
    
    /**
     Style the View Controller
     */
    private func style() {
        self.tableView.tableFooterView = UIView() //hide empty separator lines
    }
    
    /** Load events from database based on IDs */
    private func loadArtists() {
        
        if Reachability.isConnectedToNetwork() {
            Alamofire.request(.POST, Requests.allArtists).spin()
                .responseJSON { response in
                    
                    if let json = response.result.value {
                        self.tableView.artists = JSON(json)
                        
                        //if no data, display error message
                        if (self.tableView.artists!.isEmpty) {
                            self.tableView.errorLabel("No scheduled artists.", color: Style.color1)
                        }
                    }
            }
        } else {
            tableView.artists = nil
            tableView.reloadData()
            tableView.errorLabel(Text.networkFail, color: Style.color1)
        }
    }
    
    
    //MARK: - Navigation
    //********************************************************
    
//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        if let identifier = segue.identifier {
//            switch identifier {
//            case "show artist":
//                let cell = sender as! UITableViewCell
//                if let indexPath = self.tableView.indexPathForCell(cell) {
//                    let destination = segue.destinationViewController as! EventDetailsViewController
//                    
//                    // get data at specific row of json object
//                    if let event = self.tableView.artists?[indexPath.section][indexPath.row] {
//                        destination.event = Event(data: event)
//                    }
//                    
//                }
//            default: break
//                
//            }
//        }
//    }


}

//MARK: - SWReveal controller delegate
//********************************************************
extension MusicViewController: SWRevealViewControllerDelegate {
    
    /**
     Needed for disabling user interaction when menu is open
     */
    func revealController(revealController: SWRevealViewController, willMoveToPosition position: FrontViewPosition){
        self.tableView.userInteractionEnabled = (position == FrontViewPosition.Left)
    }
    
}

