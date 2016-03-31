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
import AlamofireSpinner


class HomeViewController: UIViewController {
    
    //MARK: - Outlets
    //********************************************************

    @IBOutlet weak var open: UIBarButtonItem!
    @IBOutlet weak var table: UITableView!
    
    //MARK: - Variables
    //********************************************************
    
    private var data: JSON?
    
    //MARK: - Life Cycle
    //********************************************************
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        open.target = self.revealViewController()
        open.action = Selector("revealToggle:")
        
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
    private func style() {
        self.table.estimatedRowHeight = 200.0;
        self.table.rowHeight = UITableViewAutomaticDimension;
        self.table.backgroundColor = UIColor.clearColor()
        self.table.tableFooterView = UIView()
    }
    
    /**
     Create a gradient background
     */
    private func gradient() {
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.colors = [Style.color1.CGColor, Style.lightCream.CGColor]
        gradient.locations = [0.0 , 1.0]
        gradient.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradient.endPoint = CGPoint(x: 0.0, y: 1.0)
        gradient.frame = CGRect(x: 0.0, y: 0.0, width: self.view.frame.size.width, height: self.view.frame.size.height)
        self.view.layer.insertSublayer(gradient, atIndex: 0)
    }
    
    /**
    Load highlights data. 
    */
    private func loadData () {
        
        if Reachability.isConnectedToNetwork() {
            Alamofire.request(.POST, Requests.highlights).spin()
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
    func revealController(revealController: SWRevealViewController, willMoveToPosition position: FrontViewPosition){
        self.table.userInteractionEnabled = (position == FrontViewPosition.Left)
        
    }
}

//MARK: - Table view data source
//********************************************************
extension HomeViewController: UITableViewDataSource {
    
    /**
     Number of sections in table.
     */
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    /**
     Number of rows in each section.
     */
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.data?.count ?? 0
    }
    
    /**
     Set up each cell.
     */
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = self.table.dequeueReusableCellWithIdentifier("highlight") as! HighlightsTableViewCell
        cell.data = self.data?[indexPath.row]
        
        cell.title?.font = UIFont(name: "Open Sans Condensed", size: 15)
        cell.descript?.font = UIFont(name: "Open Sans Condensed", size: 14)
        
        cell.title?.textColor = UIColor.whiteColor()
        cell.descript?.textColor = Style.cream
        cell.descript?.backgroundColor = UIColor.clearColor()
        
        //Wrap the text
        cell.title?.lineBreakMode = NSLineBreakMode.ByWordWrapping
        cell.title?.numberOfLines = 0
        
        return cell
    }
}

//MARK: - Table view delegate
//********************************************************
extension HomeViewController: UITableViewDelegate { }



