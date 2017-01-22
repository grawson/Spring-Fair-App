//
//  HighlightsTableViewController.swift
//  Spring Fair
//
//  Created by Gavi Rawson on 12/24/16.
//  Copyright © 2016 Graws Inc. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class HighlightsTableViewController: UITableViewController {
    
    // MARK: Constants
    //***********************************************************************************************
    
    struct Constants {
        static let highlightID = "highlight"
    }
    
    // MARK: Outlets
    //***********************************************************************************************
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    // MARK: Variables
    //***********************************************************************************************
    
    var highlights = [Highlight]() { didSet { tableView.reloadData() } }
    
    
    // MARK: Life Cycle
    //***********************************************************************************************
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 200
        setupMenu()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.tableFooterView = UIView()
        loadData()
        print(highlights.count)
    }
    
    // MARK: Methods
    //***********************************************************************************************
    
    fileprivate func loadData() {
        Alamofire.request(Requests.highlights, method: .get).responseJSON { [weak self] response in
            if let json = response.result.value {
                let data = JSON(json)
                var tempHighlights = [Highlight]()
                for (_, val) in data {
                    tempHighlights.append(Highlight(data: val))
                }
                self?.highlights = tempHighlights
            }
        }
    }
    
    fileprivate func setupMenu() {
        menuButton.target = self.revealViewController()
        menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
        self.revealViewController().view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        self.revealViewController().delegate = self
        self.revealViewController().panGestureRecognizer()
    }

    
    // MARK: Table ViewData Source
    //***********************************************************************************************
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return highlights.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.highlightID, for: indexPath) as! HighlightTableViewCell
        cell.title = highlights[indexPath.row].title
        cell.body = highlights[indexPath.row].body
        return cell
    }
 
    
    //MARK: Table View Delegate
    //***********************************************************************************************
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 1 ? 0 : 1
    }
}

//MARK: - SWReveal controller delegate
//********************************************************
extension HighlightsTableViewController: SWRevealViewControllerDelegate {
    
    /** Needed for disabling user interaction when menu is open */
    func revealController(_ revealController: SWRevealViewController, willMoveTo position: FrontViewPosition){
        self.tableView.isUserInteractionEnabled = (position == .left)
    }
}

