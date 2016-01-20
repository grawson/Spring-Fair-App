//
//  EventDetailsViewController.swift
//  Spring Fair
//
//  Created by Gavi Rawson on 12/20/15.
//  Copyright © 2015 Graws Inc. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire
import EventKit
import EventKitUI
import AlamofireSpinner

class EventDetailsViewController: UIViewController {

    //MARK: - Outlets
    //********************************************************
    
    @IBOutlet weak var mapButton: UIButton!
    @IBOutlet weak var button4: UIButton!
    @IBOutlet weak var calendarButton: UIButton!
    @IBOutlet weak var favoritesButton: UIButton!
    
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var location: UILabel!
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var infoBar: UIView!
    @IBOutlet weak var descript: UITextView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var zoomImage: UIImageView!
    
    
    @IBAction func addToCalendar(sender: UIButton) {
        self.createEvent()
    }
    
    
    @IBAction func mapSegue(sender: UIButton) {
        self.loadCoordinates()
    }
    
    /**
     Store or delete an event ID from favorites
     */
    @IBAction func toggleFavorite(sender: UIButton) {
        let id = self.event.getID()
        
        if (self.favEvents.contains(id)) {
            if let index = favEvents.indexOf(id) {
                self.favEvents.removeAtIndex(index)
            }
            self.favDeselected()
        } else {
            self.favEvents.append(id)
            self.favSelected()
        }
    }
    
    //MARK: - Variables
    //********************************************************    
    
    var event = Event()
    private var xCoordinate = 0.0
    private var yCoordinate = 0.0
    private let defaults = NSUserDefaults.standardUserDefaults()
    
    private var favEvents: [Int] {
        get { return defaults.objectForKey(DefaultsKeys.favEvents) as? [Int] ?? [] }  //retrive value from NSUserDefaults
        set { defaults.setObject(newValue, forKey: DefaultsKeys.favEvents) }  //store the value in NSUserDefaults
    }
    
    //MARK: - Life cycle
    //********************************************************
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.style()
        self.setupData()
        
        //for stretchy header
        self.scrollView.delegate = self
        self.scrollView.contentInset = UIEdgeInsetsMake(Style.zoomImageHeight, 0, 0, 0)
    }
    
    override func viewWillAppear(animated: Bool) {
        self.tabBarController?.tabBar.hidden = false //show tab bar
    }
    
    override func viewWillLayoutSubviews() {
        self.zoomImage.frame = CGRectMake(0, -Style.zoomImageHeight, self.scrollView.frame.width, Style.zoomImageHeight);
        name.center = zoomImage.center
        self.name.center = self.zoomImage.center
        self.updateConstraints()
    }
    
    //MARK: - Private methods
    //********************************************************
    
    /**
     Style the view controller
     */
    private func style() {
        
        //store buttons
        let buttons = [self.calendarButton, self.favoritesButton, self.mapButton, self.button4]
        
        //Round button corners
        self.mapButton.roundCorners([.TopLeft , .BottomLeft], radius: Style.largeRounded)
        self.button4.roundCorners([.TopRight , .BottomRight], radius: Style.largeRounded)
        self.favoritesButton.roundCorners([.TopRight , .BottomRight], radius: Style.largeRounded)
        self.infoBar.roundCorners([.TopLeft , .BottomLeft, .TopRight, .BottomRight], radius: Style.largeRounded)
        self.calendarButton.roundCorners([.TopLeft , .BottomLeft], radius: Style.largeRounded)
        
        //highlighted button colors
        for button in buttons {
            button.setBackgroundColor(Style.darkPurple, forState: .Highlighted)
        }
        
        //favorites button state
        let id = self.event.getID()
        self.favEvents.contains(id) ? favSelected() : favDeselected()
    }
    
    /**
     Create an event to add to the user's calendar.
     */
    private func createEvent() {
        
        //initialize event data
        let eventStore = EKEventStore()
        let event = EKEvent(eventStore: eventStore)
        event.title = self.event.getName()
        event.location = self.event.getLocation()
        event.startDate = self.event.formattedStartNSDate() ?? NSDate()
        event.endDate = self.event.formattedEndNSDate() ?? NSDate()
        event.calendar = eventStore.defaultCalendarForNewEvents
        
        //Setup "edit event" view controller
        let eventController = EKEventEditViewController()
        eventController.eventStore = eventStore
        eventController.event = event
        eventController.editViewDelegate = self
        
        //determine action based on calender access
        switch EKEventStore.authorizationStatusForEntityType(EKEntityType.Event) {
        case .Authorized:
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.presentViewController(eventController, animated: true, completion: nil)
            })
            
        case .NotDetermined:
            eventStore.requestAccessToEntityType(EKEntityType.Event, completion: { (granted, error) -> Void in
                if granted == true {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.presentViewController(eventController, animated: true, completion: nil)
                    })
                }
            })
        case .Denied, .Restricted:
            let vc = CustomAlertViewController()
            vc.alert.titleText = "Uh Oh..."
            vc.alert.messageText = Text.networkFail
            self.addChildViewController(vc)
            self.view.addSubview(vc.view)
            return
        }
    }
    
    /**
    Update the layout constraints to allow for stretchy header
    */
    private func updateConstraints() {
        self.name.center = self.zoomImage.center
        let yConstraint = NSLayoutConstraint(
            item: self.infoBar, attribute: .Top, relatedBy: .Equal, toItem: self.contentView,
            attribute: .Top, multiplier: 1.0, constant: 10
        )
        NSLayoutConstraint.activateConstraints([yConstraint])
    }
  
    /**
    Set up the data on the page 
    */
    private func setupData() {
        self.name.text = event.getName().uppercaseString
        self.time.text  = self.event.getStartTime() + " - " + self.event.getEndTime()
        self.location.text = event.getLocation()
        self.descript.text = event.getDescription()
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
        
//        let mutableURLRequest = NSMutableURLRequest(URL: NSURL(string: Requests.coordinates)!)
//        mutableURLRequest.HTTPMethod = Method.POST.rawValue
        let outData = ["name": self.event.formattedLocation()]
//        let encodedURLRequest = ParameterEncoding.JSON.encode(mutableURLRequest, parameters: outData).0
//        let data = encodedURLRequest.HTTPBody!
//        
//        print(outData["name"])
//        
//        if Reachability.isConnectedToNetwork() {
//            Alamofire.upload(mutableURLRequest, data: data)
//                .progress { _, _, _ in
//                    UIApplication.sharedApplication().networkActivityIndicatorVisible = true
//                }
//                .responseJSON { response in
//                    UIApplication.sharedApplication().networkActivityIndicatorVisible = false
//                    
//                    if let json = response.result.value {
//                        let data = JSON(json)
//                        print(response)
//
//                        //if data present
//                        if !(data.isEmpty) {
//                            self.xCoordinate = data[0]["xcoordinate"].doubleValue
//                            self.yCoordinate = data[0]["ycoordinate"].doubleValue
//                            self.performSegueWithIdentifier("show map", sender: self)
//                        }
//                    }
//            }
//        } else {
//            let vc = CustomAlertViewController()
//            vc.alert.titleText = "Uh Oh..."
//            vc.alert.messageText = Text.networkFail
//            self.addChildViewController(vc)
//            self.view.addSubview(vc.view)
//        }
        
        
        
        Alamofire.request(.POST, Requests.coordinates, parameters: outData)
            .progress { _, _, _ in
//                UIApplication.sharedApplication().networkActivityIndicatorVisible = true
            }
            .spin().responseJSON { response in

                if let json = response.result.value {
                    let data = JSON(json)
                    
                    //if data present
                    if !(data.isEmpty) {
                        self.xCoordinate = data[0]["xcoordinate"].doubleValue
                        self.yCoordinate = data[0]["ycoordinate"].doubleValue
                        self.performSegueWithIdentifier("show map", sender: self)
                    }
                } else {
                    let vc = CustomAlertViewController()
                    vc.alert.titleText = "Uh Oh..."
                    vc.alert.messageText = Text.networkFail
                    self.addChildViewController(vc)
                    self.view.addSubview(vc.view)
                }
        }
    }

    //MARK: - Navigation
    //********************************************************
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if segue.identifier == "show map" {
            //let nc = segue.destinationViewController as! UINavigationController
            //let vc = nc.topViewController as! GoogleMapsViewController
            let vc = segue.destinationViewController as! GoogleMapsViewController
            vc.xCoordinate = self.xCoordinate
            vc.yCoordinate = self.yCoordinate
            vc.locationName = self.event.getLocation()
        }
    }
}


//MARK: - UIScrollView delegate
//********************************************************
extension EventDetailsViewController: UIScrollViewDelegate {
    
    /**
     Change the frame when scrolling - for stretchy header
     */
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let yOffset = self.scrollView.contentOffset.y
        if (yOffset < -Style.zoomImageHeight) {
            var f = self.zoomImage.frame
            f.origin.y = yOffset
            f.size.height = -yOffset
            self.zoomImage.frame = f
            self.updateConstraints()
        }
    }
}


//MARK: - UIScrollView delegate
//********************************************************
extension EventDetailsViewController: EKEventEditViewDelegate {
    
    /**
     Dismiss the "add event" presentation.
     */
    func eventEditViewController(controller: EKEventEditViewController,
        didCompleteWithAction action: EKEventEditViewAction){
            self.dismissViewControllerAnimated(true, completion: nil)
    }
}





