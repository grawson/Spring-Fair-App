//
//  VendorDetailsViewController.swift
//  Spring Fair
//
//  Created by Gavi Rawson on 12/23/15.
//  Copyright © 2015 Graws Inc. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire
//import AlamofireSpinner
import GRCustomAlert

class VendorDetailsViewController: UIViewController {

    //MARK: - Outlets
    //********************************************************
    
    @IBOutlet weak var websiteButton: UIButton!
    @IBOutlet weak var type: UILabel!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var zoomImage: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var favoritesButton: UIButton!
    @IBOutlet weak var descript: UITextView!
    @IBOutlet weak var textCardView: UIView!
    @IBOutlet weak var buttonsCardView: UIView!
    @IBOutlet weak var infoTextCardView: UIView!
    @IBOutlet weak var mapButton: UIButton!
    @IBOutlet weak var locationTextView: UILabel!
    @IBOutlet weak var timeTextView: UILabel!
    @IBOutlet weak var typeIcon: UIImageView!
    
    
    @IBAction func mapSegue(_ sender: UIButton) {
        loadCoordinates()
    }
  
    /**
     Add or remove favorite ID from storage
     */
    @IBAction func toggleFavorite(_ sender: UIButton) {
        let id = self.vendor.getID()
        
        if (self.favVendors.contains(id)) {
            if let index = favVendors.index(of: id) {
                favVendors.remove(at: index)
            }
            favDeselected()
        } else {
            self.favVendors.append(id)
            favSelected()
        }
    }
    
    /** Open the vendor's website */
    @IBAction func openWebsite(_ sender: UIButton) {
        if let url = url, let address =  URL(string: url) {
            UIApplication.shared.openURL(address)
        }
    }
    
    //MARK: - Variables
    //********************************************************
    
    fileprivate var xCoordinate = 0.0
    fileprivate var yCoordinate = 0.0
    fileprivate var url: String?
    var vendor = Vendor()
    fileprivate let defaults = UserDefaults.standard
    var key: String?
    var artVendor: Bool?
    
    fileprivate var favVendors: [Int] {
        get { return defaults.object(forKey: key!) as? [Int] ?? [] }  //retrive value from NSUserDefaults
        set { defaults.set(newValue, forKey: key!) }  //store the value in NSUserDefaults
    }
    
    //MARK: - Life cycle
    //********************************************************
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        style()
        setupData() //setup data based on event
        
        self.scrollView.delegate = self
        self.scrollView.contentInset = UIEdgeInsetsMake(Style.zoomImageHeight, 0, 0, 0)
        //self.scrollView.addSubview(self.zoomImage)
        
    }
    
    override func viewWillLayoutSubviews() {
        self.zoomImage.frame = CGRect(x: 0, y: -Style.zoomImageHeight, width: self.scrollView.frame.width, height: Style.zoomImageHeight);
        name.center = zoomImage.center
        self.name.center = self.zoomImage.center
        updateConstraints()
    }
    
    
    //MARK: - Private methods
    //********************************************************
    
    /**
     Style the view controller
     */
    fileprivate func style() {
        
        //set button highlighted states
        let buttons = [websiteButton, favoritesButton, mapButton]
        for button in buttons {
            button?.setBackgroundColor(Style.darkPurple, forState: .highlighted)
        }
        
        //Round button corners
        self.websiteButton.roundCorners([.topLeft, .topRight, .bottomLeft, .bottomRight], radius: Style.smallestRounded)
        self.favoritesButton.roundCorners([.topLeft, .topRight, .bottomLeft, .bottomRight], radius: Style.smallestRounded)
        self.mapButton.roundCorners([.topLeft, .topRight, .bottomLeft, .bottomRight], radius: Style.smallestRounded)

        
        //state of favorites button
        let id = self.vendor.getID()
        if (self.favVendors.contains(id)) {
            favSelected()
        } else {
            favDeselected()
        }
        
        //set shadows
        let cards = [ buttonsCardView, textCardView, infoTextCardView ]
        for card in cards {
            card?.setCardShadow()
        }
        
        //set icon if art vendor
        if let artVendor = artVendor {
            if artVendor {
                typeIcon.image = UIImage(named: "art_purple")
            }
        }
    }
    
    /**
     Update constraints for stretchy headers.
     */
    fileprivate func updateConstraints() {
        self.name.center = self.zoomImage.center
        let yConstraint = NSLayoutConstraint(
            item: self.buttonsCardView, attribute: .top, relatedBy: .equal, toItem: self.contentView,
            attribute: .top, multiplier: 1.0, constant: 10
        )
        NSLayoutConstraint.activate([yConstraint])
    }
    
    /** 
     Set up the data on the page 
     */
    fileprivate func setupData() {
        name.text = vendor.getName().uppercased()
        type.text = vendor.getType()
        descript.text = vendor.getDescription()
        locationTextView.text = vendor.location
        url = vendor.website
        timeTextView.text  = vendor.startTime + " - " + vendor.endTime
    }
    
    /** 
     Change state of favorites button when selected 
     */
    fileprivate func favSelected() {
        favoritesButton.setTitle("Added to Favorites", for: UIControlState())
        //favoritesButton.setTitleColor(style.color1, forState: .Normal)
        favoritesButton.backgroundColor = Style.darkPurple
    }
    
    /** 
     Change state of favorites button when deselected 
     */
    fileprivate func favDeselected() {
        favoritesButton.setTitle("Add to Favorites", for: UIControlState())
        //favoritesButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        favoritesButton.backgroundColor = Style.color1
    }
    
    /**
     Load coordinates from database based on IDs
     */
    fileprivate func loadCoordinates() {
        mapButton.isEnabled = false   //disable while loading coordinates
        let outData = ["name": self.vendor.formattedLocation()]
        
        if Reachability.isConnectedToNetwork() {
            Alamofire.request(Requests.coordinates, method: .post, parameters: outData)
                .responseJSON { response in
                    
                    if let json = response.result.value {
                        let data = JSON(json)
                        
                        //if data present
                        if !(data.isEmpty) {
                            self.xCoordinate = data[0]["xcoordinate"].doubleValue
                            self.yCoordinate = data[0]["ycoordinate"].doubleValue
                            self.performSegue(withIdentifier: "show_map", sender: self)
                        }
                    }
            }
        } else {
            let vc = CustomAlertViewController()
            vc.alert.titleText = "Uh Oh..."
            vc.alert.messageText = Text.networkFail
            self.addChildViewController(vc)
            self.view.addSubview(vc.view)
        }
        mapButton.isEnabled = true
    }
    
    //MARK: - Navigation
    //********************************************************
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        if segue.identifier == "show_map" {
            //let nc = segue.destinationViewController as! UINavigationController
            //let vc = nc.topViewController as! GoogleMapsViewController
            let vc = segue.destination as! GoogleMapsViewController
            vc.xCoordinate = self.xCoordinate
            vc.yCoordinate = self.yCoordinate
            vc.locationName = self.vendor.location
        }
    }

}

//MARK: - Scroll View Delegate
//********************************************************
extension VendorDetailsViewController: UIScrollViewDelegate {
    
    /**
     Change frame when scrolling
     */
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let yOffset = self.scrollView.contentOffset.y
        if (yOffset < -Style.zoomImageHeight) {
            var f = self.zoomImage.frame
            f.origin.y = yOffset
            f.size.height = -yOffset
            self.zoomImage.frame = f
            updateConstraints()
        }
    }
}




