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
        self.menu.action = #selector(SWRevealViewController.revealToggle(_:))
        
        //opens slide menu with gesture
        self.revealViewController().view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        
        // Disable user interaction when menu is open
        self.revealViewController().delegate = self
        self.revealViewController().panGestureRecognizer()
        
        self.tableView.delegate = self.tableView
        self.tableView.dataSource = self.tableView
        
        style()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.loadArtists()
    }
    
    //MARK: - Private methods
    //********************************************************
    
    /**
     Style the View Controller
     */
    fileprivate func style() {
        self.tableView.tableFooterView = UIView() //hide empty separator lines
    }
    
    /** Load all music from database */
    fileprivate func loadArtists() {
        
        guard Reachability.isConnectedToNetwork() else {
            tableView.artists = nil
            tableView.reloadData()
            tableView.errorLabel(Text.networkFail, color: Style.color1)
            return
        }
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        Alamofire.request(Requests.allArtists, method: .get).responseJSON { [weak self] response in
            
            guard let strongSelf = self else { return }
            
            // data result found
            if let json = response.result.value {
                let data = JSON(json)
                DispatchQueue.main.async {
                    strongSelf.tableView.artists = data
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
            case "show artist":
                let cell = sender as! UITableViewCell
                if let indexPath = self.tableView.indexPath(for: cell) {
                    let destination = segue.destination as! MusicDetailsViewController
                    
                    // get data at specific row of json object
                    if let artist = self.tableView.artists?[indexPath.section][indexPath.row] {
                        destination.artist = Artist(data: artist)
                        print(artist)
                    }
                    
                }
            default: break
                
            }
        }
    }


}

//MARK: - SWReveal controller delegate
//********************************************************
extension MusicViewController: SWRevealViewControllerDelegate {
    
    /**
     Needed for disabling user interaction when menu is open
     */
    func revealController(_ revealController: SWRevealViewController, willMoveTo position: FrontViewPosition){
        self.tableView.isUserInteractionEnabled = (position == FrontViewPosition.left)
    }
    
}

