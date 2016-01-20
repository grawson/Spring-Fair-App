//
//  VendorsViewController.swift
//  Spring Fair
//
//  Created by Gavi Rawson on 12/27/15.
//  Copyright © 2015 Graws Inc. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import AlamofireSpinner

class VendorsViewController: UIViewController {

    //MARK: - Outlets
    //********************************************************
    
    @IBOutlet weak var menu: UIBarButtonItem!
    @IBOutlet weak var tableView: VendorsTableView!
    
    //MARK: - Life cycle
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
        
        self.style()
    }
    
    override func viewWillAppear(animated: Bool) {
        self.loadEvents()
    }
    
    //MARK: - Private methods
    //********************************************************
    
    /**
     Style the View Controller
     */
    private func style() {
        self.tableView.tableFooterView = UIView() //hide empty separator lines
    }
    
    /** 
    Load events from database based on favorite IDs 
    */
    private func loadEvents() {
        
        if Reachability.isConnectedToNetwork() {
            Alamofire.request(.POST, Requests.allVendors).spin()
                .responseJSON { response in
                    
                    if let json = response.result.value {
                        self.tableView.vendors = JSON(json)
                        
                        //if no data, display error message
                        if (self.tableView.vendors!.isEmpty) {
                            let text = "No current vendors"
                            self.tableView.errorLabel(text, color: Style.color1)
                        }
                    }
            }
        } else {
            self.tableView.errorLabel(Text.networkFail, color: Style.color1)
        }
       
    }
    
 
    //MARK: - Navigation
    //********************************************************
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            switch identifier {
            case "show vendor":
                let cell = sender as! UITableViewCell
                if let indexPath = self.tableView.indexPathForCell(cell) {
                    let destination = segue.destinationViewController as! VendorDetailsViewController
                    
                    // get data at specific row of json object
                    if let vendor = self.tableView.vendors?[indexPath.row] {
                        destination.vendor = Vendor(data: vendor)
                    }
                    
                }
            default: break
                
            }
        }
    }
}


//MARK: - SWReveal controller delegate
//********************************************************
extension VendorsViewController: SWRevealViewControllerDelegate {
    
    /**
     Needed for disabling user interaction when menu is open
     */
    func revealController(revealController: SWRevealViewController, willMoveToPosition position: FrontViewPosition){
        self.tableView.userInteractionEnabled = (position == FrontViewPosition.Left)
    }

}




