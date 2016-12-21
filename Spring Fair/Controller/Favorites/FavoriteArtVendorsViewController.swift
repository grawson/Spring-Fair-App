//
//  FavoriteArtVendorsViewController.swift
//  Spring Fair
//
//  Created by Gavi Rawson on 12/27/15.
//  Copyright © 2015 Graws Inc. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
////import AlamofireSpinner


class FavoriteArtVendorsViewController: UIViewController {
    
    //MARK: - Outlets
    //********************************************************
    
    @IBOutlet weak var open: UIBarButtonItem!
    @IBOutlet weak var tableView: VendorsTableView!
    
    //MARK: - Variables
    //********************************************************
    
    fileprivate let defaults = UserDefaults.standard
    
    ///  retrive IDs fron user defaults
    fileprivate var idDict: [String: [Int]] {
        get {
            let ids = defaults.object(forKey: DefaultsKeys.favArtVendors) as? [Int] ?? []
            return ["ids": ids]
        }
    }
    
    //MARK: - life cycle
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
        
        style();
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false //show tab bar
        self.loadVendors(self.idDict)
    }
    
    //MARK: - private methods
    //********************************************************
    
    /**
     Style the view controller
     */
    fileprivate func style() {
        self.tableView.tableFooterView = UIView() //hide empty separator lines
        
    }
    
    /**
     Load vendors from database based on IDs
     */
    fileprivate func loadVendors(_ ids: [String: [Int]]) {
        
        if Reachability.isConnectedToNetwork() {
            Alamofire.request(Requests.artVendorID, method: .post, parameters: ids)
                .responseJSON { response in
                    
                    if let json = response.result.value {
                        self.tableView.vendors = JSON(json)
                        
                        //if no data, display error message
                        if (self.tableView.vendors!.isEmpty) {
                            let text = "No favorite art vendors added."
                            self.tableView.errorLabel(text, color: Style.color1)
                        }
                    }
            }
        } else {
            tableView.vendors = nil
            tableView.reloadData()
            self.tableView.errorLabel(Text.networkFail, color: Style.color1)
        }
    }
    
    //MARK: - Navigation
    //********************************************************
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            switch identifier {
            case "show_art_vendor":
                let cell = sender as! UITableViewCell
                if let indexPath = tableView.indexPath(for: cell) {
                    let destination = segue.destination as! VendorDetailsViewController
                    
                    // get data at specific row of json object
                    if let vendor = self.tableView.vendors?[indexPath.row] {
                        destination.vendor = Vendor(data: vendor)
                        destination.key = DefaultsKeys.favArtVendors
                        destination.artVendor = true
                    }
                    
                }
            default: break
                
            }
        }
    }
}


//MARK: - SW Reveal controller delegate
//********************************************************
extension FavoriteArtVendorsViewController: SWRevealViewControllerDelegate {
    
    /**
     Needed for disabling user interaction when menu is open
     */
    func revealController(_ revealController: SWRevealViewController, willMoveTo position: FrontViewPosition){
        self.tableView.isUserInteractionEnabled = (position == FrontViewPosition.left)
    }
}


