//
//  VendorDetailsViewController.swift
//  Spring Fair
//
//  Created by Gavi Rawson on 12/23/15.
//  Copyright © 2015 Graws Inc. All rights reserved.
//

import UIKit
import SwiftyJSON

class VendorDetailsViewController: UIViewController {

    //MARK: - Outlets
    //********************************************************
    
    @IBOutlet weak var websiteButton: UIButton!
    @IBOutlet weak var infoBarView: UIView!
    @IBOutlet weak var type: UILabel!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var zoomImage: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var favoritesButton: UIButton!
    @IBOutlet weak var descript: UITextView!
    @IBOutlet weak var textCardView: UIView!
    @IBOutlet weak var buttonsCardView: UIView!
    
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
    
    /** OPen the vendor's website */
    @IBAction func openWebsite(sender: UIButton) {
        let websiteAddress = NSURL(string: "google.com") // TODO: change url
        UIApplication.sharedApplication().openURL(websiteAddress!)
    }
    
    //MARK: - Variables
    //********************************************************
    
    var vendor = Vendor()
    private let defaults = NSUserDefaults.standardUserDefaults()
    
    private var favVendors: [Int] {
        get { return defaults.objectForKey(DefaultsKeys.favVendors) as? [Int] ?? [] }  //retrive value from NSUserDefaults
        set { defaults.setObject(newValue, forKey: DefaultsKeys.favVendors) }  //store the value in NSUserDefaults
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
        let buttons = [self.websiteButton, self.favoritesButton]
        for button in buttons {
            button.setBackgroundColor(Style.darkPurple, forState: .Highlighted)
        }
        
        //Round button corners
        self.websiteButton.roundCorners([.TopLeft, .TopRight, .BottomLeft, .BottomRight], radius: Style.smallestRounded)
        self.favoritesButton.roundCorners([.TopLeft, .TopRight, .BottomLeft, .BottomRight], radius: Style.smallestRounded)
        self.infoBarView.roundCorners([.TopLeft, .TopRight, .BottomLeft, .BottomRight], radius: Style.smallestRounded)
        
        //state of favorites button
        let id = self.vendor.getID()
        if (self.favVendors.contains(id)) {
            favSelected()
        } else {
            favDeselected()
        }
        
        //set shadows
        let cards = [ buttonsCardView, textCardView ]
        for card in cards {
            card.setCardShadow()
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
        self.name.text = vendor.getName().uppercaseString
        self.type.text = vendor.getType()
        self.descript.text = vendor.getDescription()
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
}

//MARK: - Scroll View Delegate
//********************************************************
extension VendorDetailsViewController: UIScrollViewDelegate {
    
    /**
     Change frame when scrolling
     */
    func scrollViewDidScroll(scrollView: UIScrollView) {
//        let yOffset = self.scrollView.contentOffset.y
//        if (yOffset < -Style.zoomImageHeight) {
//            var f = self.zoomImage.frame
//            f.origin.y = yOffset
//            f.size.height = -yOffset
//            self.zoomImage.frame = f
//            updateConstraints()
//        }
    }
}




