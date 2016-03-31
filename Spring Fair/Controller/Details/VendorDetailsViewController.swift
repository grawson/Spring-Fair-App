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
import AlamofireSpinner
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
    
    
    @IBAction func mapSegue(sender: UIButton) {
        loadCoordinates()
    }
  
    /**
     Add or remove favorite ID from storage
     */
    @IBAction func toggleFavorite(sender: UIButton) {
        let id = self.vendor.getID()
        
        if (self.favVendors.contains(id)) {
            if let index = favVendors.indexOf(id) {
                favVendors.removeAtIndex(index)
            }
            favDeselected()
        } else {
            self.favVendors.append(id)
            favSelected()
        }
    }
    
    /** Open the vendor's website */
    @IBAction func openWebsite(sender: UIButton) {
        if let url = url, address =  NSURL(string: url) {
            UIApplication.sharedApplication().openURL(address)
        }
    }
    
    //MARK: - Variables
    //********************************************************
    
    private var xCoordinate = 0.0
    private var yCoordinate = 0.0
    private var url: String?
    var vendor = Vendor()
    private let defaults = NSUserDefaults.standardUserDefaults()
    var key: String?
    var artVendor: Bool?
    
    private var favVendors: [Int] {
        get { return defaults.objectForKey(key!) as? [Int] ?? [] }  //retrive value from NSUserDefaults
        set { defaults.setObject(newValue, forKey: key!) }  //store the value in NSUserDefaults
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
        self.zoomImage.frame = CGRectMake(0, -Style.zoomImageHeight, self.scrollView.frame.width, Style.zoomImageHeight);
        name.center = zoomImage.center
        self.name.center = self.zoomImage.center
        updateConstraints()
    }
    
    
    //MARK: - Private methods
    //********************************************************
    
    /**
     Style the view controller
     */
    private func style() {
        
        //set button highlighted states
        let buttons = [websiteButton, favoritesButton, mapButton]
        for button in buttons {
            button.setBackgroundColor(Style.darkPurple, forState: .Highlighted)
        }
        
        //Round button corners
        self.websiteButton.roundCorners([.TopLeft, .TopRight, .BottomLeft, .BottomRight], radius: Style.smallestRounded)
        self.favoritesButton.roundCorners([.TopLeft, .TopRight, .BottomLeft, .BottomRight], radius: Style.smallestRounded)
        self.mapButton.roundCorners([.TopLeft, .TopRight, .BottomLeft, .BottomRight], radius: Style.smallestRounded)

        
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
            card.setCardShadow()
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
    private func updateConstraints() {
        self.name.center = self.zoomImage.center
        let yConstraint = NSLayoutConstraint(
            item: self.buttonsCardView, attribute: .Top, relatedBy: .Equal, toItem: self.contentView,
            attribute: .Top, multiplier: 1.0, constant: 10
        )
        NSLayoutConstraint.activateConstraints([yConstraint])
    }
    
    /** 
     Set up the data on the page 
     */
    private func setupData() {
        name.text = vendor.getName().uppercaseString
        type.text = vendor.getType()
        descript.text = vendor.getDescription()
        locationTextView.text = vendor.location
        url = vendor.website
        timeTextView.text  = vendor.startTime + " - " + vendor.endTime
    }
    
    /** 
     Change state of favorites button when selected 
     */
    private func favSelected() {
        favoritesButton.setTitle("Added to Favorites", forState: .Normal)
        //favoritesButton.setTitleColor(style.color1, forState: .Normal)
        favoritesButton.backgroundColor = Style.darkPurple
    }
    
    /** 
     Change state of favorites button when deselected 
     */
    private func favDeselected() {
        favoritesButton.setTitle("Add to Favorites", forState: .Normal)
        //favoritesButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        favoritesButton.backgroundColor = Style.color1
    }
    
    /**
     Load coordinates from database based on IDs
     */
    private func loadCoordinates() {
        mapButton.enabled = false   //disable while loading coordinates
        let outData = ["name": self.vendor.formattedLocation()]
        
        if Reachability.isConnectedToNetwork() {
            Alamofire.request(.POST, Requests.coordinates, parameters: outData).spin()
                .responseJSON { response in
                    
                    if let json = response.result.value {
                        let data = JSON(json)
                        
                        //if data present
                        if !(data.isEmpty) {
                            self.xCoordinate = data[0]["xcoordinate"].doubleValue
                            self.yCoordinate = data[0]["ycoordinate"].doubleValue
                            self.performSegueWithIdentifier("show_map", sender: self)
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
        mapButton.enabled = true
    }
    
    //MARK: - Navigation
    //********************************************************
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if segue.identifier == "show_map" {
            //let nc = segue.destinationViewController as! UINavigationController
            //let vc = nc.topViewController as! GoogleMapsViewController
            let vc = segue.destinationViewController as! GoogleMapsViewController
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
    func scrollViewDidScroll(scrollView: UIScrollView) {
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




