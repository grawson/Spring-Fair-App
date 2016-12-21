//
//  HomeController.swift
//  Spring Fair
//
//  Created by Gavi Rawson on 11/22/15.
//  Copyright © 2015 Graws Inc. All rights reserved.
//


import UIKit
import Alamofire
import SwiftyJSON
//import AlamofireSpinner


class HomeViewController: UIViewController {
    
    //MARK: - Outlets
    //********************************************************

    @IBOutlet weak var open: UIBarButtonItem!
    @IBOutlet weak var table: UITableView!
    
    //MARK: - Variables
    //********************************************************
    
    fileprivate var data: JSON?
    
    //MARK: - Life Cycle
    //********************************************************
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        open.target = self.revealViewController()
        open.action = #selector(SWRevealViewController.revealToggle(_:))
        
        //opens slide menu with gesture
        self.revealViewController().view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        
        //Disable user interaction when menu is open
        self.revealViewController().delegate = self
        self.revealViewController().panGestureRecognizer()
        
        self.table.delegate = self
        self.table.dataSource = self
        
        self.gradient()
        self.loadData()
        self.style()
    }
    
    //MARK: - Private methods
    //********************************************************
    
    /**
     Style the view controller
     */
    fileprivate func style() {
        self.table.estimatedRowHeight = 200.0;
        self.table.rowHeight = UITableViewAutomaticDimension;
        self.table.backgroundColor = UIColor.clear
        self.table.tableFooterView = UIView()
    }
    
    /**
     Create a gradient background
     */
    fileprivate func gradient() {
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.colors = [Style.color1.cgColor, Style.lightCream.cgColor]
        gradient.locations = [0.0 , 1.0]
        gradient.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradient.endPoint = CGPoint(x: 0.0, y: 1.0)
        gradient.frame = CGRect(x: 0.0, y: 0.0, width: self.view.frame.size.width, height: self.view.frame.size.height)
        self.view.layer.insertSublayer(gradient, at: 0)
    }
    
    /**
    Load highlights data. 
    */
    fileprivate func loadData () {
        
        if Reachability.isConnectedToNetwork() {
            Alamofire.request(Requests.highlights, method: .post)
                .responseJSON { response in
                    
                    if let json = response.result.value {
                        let data = JSON(json)
                        self.data = data
                        self.table.reloadData()
                        
                        //if no data, display error message
                        if (data.isEmpty) {
                            let text = "No highlights."
                            self.table.errorLabel(text, color: Style.cream)
                        }
                    }
            }
        } else {
            self.table.errorLabel(Text.networkFail, color: Style.cream)
        }
    }
}

//MARK: - SWReveal Controller delegate
//********************************************************
extension HomeViewController: SWRevealViewControllerDelegate {
    
    /**
     Disable view controller when menu is open
     */
    func revealController(_ revealController: SWRevealViewController, willMoveTo position: FrontViewPosition){
        self.table.isUserInteractionEnabled = (position == FrontViewPosition.left)
        
    }
}

//MARK: - Table view data source
//********************************************************
extension HomeViewController: UITableViewDataSource {
    
    /**
     Number of sections in table.
     */
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    /**
     Number of rows in each section.
     */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.data?.count ?? 0
    }
    
    /**
     Set up each cell.
     */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = self.table.dequeueReusableCell(withIdentifier: "highlight") as! HighlightsTableViewCell
        cell.data = self.data?[indexPath.row]
        
        cell.title?.font = UIFont(name: "Open Sans Condensed", size: 15)
        cell.descript?.font = UIFont(name: "Open Sans Condensed", size: 14)
        
        cell.title?.textColor = UIColor.white
        cell.descript?.textColor = Style.cream
        cell.descript?.backgroundColor = UIColor.clear
        
        //Wrap the text
        cell.title?.lineBreakMode = NSLineBreakMode.byWordWrapping
        cell.title?.numberOfLines = 0
        
        return cell
    }
}

//MARK: - Table view delegate
//********************************************************
extension HomeViewController: UITableViewDelegate { }



