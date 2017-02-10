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
//import AlamofireSpinner

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
        self.menu.action = #selector(SWRevealViewController.revealToggle(_:))
        
        //opens slide menu with gesture
        self.revealViewController().view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        
        // Disable user interaction when menu is open
        self.revealViewController().delegate = self
        self.revealViewController().panGestureRecognizer()
        
        self.tableView.delegate = self.tableView
        self.tableView.dataSource = self.tableView
        
        self.style()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false //show tab bar
        self.loadVendors()
    }
    
    //MARK: - Private methods
    //********************************************************
    
    /**
     Style the View Controller
     */
    fileprivate func style() {
        self.tableView.tableFooterView = UIView() //hide empty separator lines
    }
    
    /** 
    Load events from database based on favorite IDs 
    */
    fileprivate func loadVendors() {
        
        guard Reachability.isConnectedToNetwork() else {
            tableView.vendors = nil
            tableView.reloadData()
            tableView.errorLabel(Text.networkFail, color: Style.color1)
            return
        }
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        Alamofire.request(Requests.allVendors, method: .get).responseJSON { [weak self] response in
            
            guard let strongSelf = self else { return }
            
            // data result found
            if let json = response.result.value {
                let data = JSON(json)
                DispatchQueue.main.async {
                    strongSelf.tableView.vendors = data
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
            case "show_vendor":
                let cell = sender as! UITableViewCell
                if let indexPath = self.tableView.indexPath(for: cell) {
                    let destination = segue.destination as! VendorDetailsViewController
                    
                    // get data at specific row of json object
                    if let vendor = self.tableView.vendors?[indexPath.row] {
                        destination.vendor = Vendor(data: vendor)
                        destination.key = DefaultsKeys.favVendors
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
    func revealController(_ revealController: SWRevealViewController, willMoveTo position: FrontViewPosition){
        self.tableView.isUserInteractionEnabled = (position == FrontViewPosition.left)
    }

}




