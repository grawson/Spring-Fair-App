//
//  MusicDetailsViewController.swift
//  Spring Fair
//
//  Created by Gavi Rawson on 3/5/16.
//  Copyright © 2016 Graws Inc. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire
import EventKit
import EventKitUI


class MusicDetailsViewController: UIViewController {
    
    //MARK: - Outlets
    //********************************************************
    
    @IBOutlet weak var mapButton: UIButton!
    @IBOutlet weak var calendarButton: UIButton!
    @IBOutlet weak var favoritesButton: UIButton!
    @IBOutlet weak var sampleButton: UIButton!
    
    @IBOutlet weak var genre: UILabel!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var location: UILabel!
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var zoomImage: UIImageView!
    @IBOutlet weak var buttonsCardView: UIView!
    @IBOutlet weak var infoTextCardView: UIView!
    
    
    @IBAction func addToCalendar(_ sender: UIButton) {
        self.createEvent()
    }
    
    
    @IBAction func mapSegue(_ sender: UIButton) {
        self.loadCoordinates()
    }
    
    /** Sample an artist's music */
    @IBAction func sample(_ sender: UIButton) {
        if let url = URL(string: artist.sample) {
            UIApplication.shared.openURL(url)
        }
    }
    
    /**
     Store or delete an event ID from favorites
     */
    @IBAction func toggleFavorite(_ sender: UIButton) {
        let id = self.artist.getID()
        
        if (self.favEvents.contains(id)) {
            if let index = favEvents.index(of: id) {
                self.favEvents.remove(at: index)
            }
            self.favDeselected()
        } else {
            self.favEvents.append(id)
            self.favSelected()
        }
    }
    
    //MARK: - Variables
    //********************************************************
    
    var artist = Artist() //TODO: Create own model for artist
    fileprivate var xCoordinate = 0.0
    fileprivate var yCoordinate = 0.0
    fileprivate let defaults = UserDefaults.standard
    
    fileprivate var favEvents: [Int] {
        get { return defaults.object(forKey: DefaultsKeys.favArtists) as? [Int] ?? [] }  //retrive value from NSUserDefaults
        set { defaults.set(newValue, forKey: DefaultsKeys.favArtists) }          //store the value in NSUserDefaults
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

    
    override func viewWillLayoutSubviews() {
        self.zoomImage.frame = CGRect(x: 0, y: -Style.zoomImageHeight, width: self.scrollView.frame.width, height: Style.zoomImageHeight);
        name.center = zoomImage.center
        self.name.center = self.zoomImage.center
        self.updateConstraints()
    }
    
    //MARK: - Private methods
    //********************************************************
    
    /**
    Style the view controller
    */
    fileprivate func style() {
        
        //store buttons
        let buttons = [self.calendarButton, self.favoritesButton, self.mapButton, sampleButton]
        
        //Round button corners
        self.mapButton.roundCorners([.topLeft , .bottomLeft, .topRight, .bottomRight], radius: Style.smallestRounded)
        self.favoritesButton.roundCorners([.topLeft , .bottomLeft, .topRight, .bottomRight], radius: Style.smallestRounded)
        self.calendarButton.roundCorners([.topLeft , .bottomLeft, .topRight, .bottomRight], radius: Style.smallestRounded)
        sampleButton.roundCorners([.topLeft , .bottomLeft, .topRight, .bottomRight], radius: Style.smallestRounded)

        
        //highlighted button colors
        for button in buttons {
            button?.setBackgroundColor(Style.darkPurple, forState: .highlighted)
        }
        
        //favorites button state
        let id = self.artist.getID()
        self.favEvents.contains(id) ? favSelected() : favDeselected()
        
        //set shadows
        infoTextCardView.setCardShadow()
        buttonsCardView.setCardShadow()
    }
    
    /**
     Create an event to add to the user's calendar.
     */
    fileprivate func createEvent() {
        
        //initialize event data
        let eventStore = EKEventStore()
        let event = EKEvent(eventStore: eventStore)
        event.title = self.artist.getName()
        event.location = self.artist.getLocation()
        event.startDate = self.artist.formattedStartNSDate() ?? Date()
        event.endDate = self.artist.formattedEndNSDate() ?? Date()
        event.calendar = eventStore.defaultCalendarForNewEvents
        
        //Setup "edit event" view controller
        let eventController = EKEventEditViewController()
        eventController.eventStore = eventStore
        eventController.event = event
        eventController.editViewDelegate = self
        
        //determine action based on calender access
        switch EKEventStore.authorizationStatus(for: EKEntityType.event) {
        case .authorized:
            DispatchQueue.main.async(execute: { () -> Void in
                self.present(eventController, animated: true, completion: nil)
            })
            
        case .notDetermined:
            eventStore.requestAccess(to: EKEntityType.event, completion: { (granted, error) -> Void in
                if granted == true {
                    DispatchQueue.main.async(execute: { () -> Void in
                        self.present(eventController, animated: true, completion: nil)
                    })
                }
            })
        case .denied, .restricted:
            let alert = UIAlertController(title: Text.accessFailureTitle, message: Text.accessFailureMessage, preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(ok)
            present(alert, animated: true, completion: nil)
            return
        }
    }
    
    /**
     Update the layout constraints to allow for stretchy header
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
        self.name.text = artist.getName().uppercased()
        self.time.text  = artist.getStartTime() + " - " + artist.getEndTime()
        self.location.text = artist.getLocation()
        genre.text = artist.genre
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
        let outData = ["name": artist.formattedLocation()]
        
        if Reachability.isConnectedToNetwork() {
            Alamofire.request(Requests.coordinates, method: .post, parameters: outData)
                .responseJSON { response in
                    
                    if let json = response.result.value {
                        let data = JSON(json)
                        
                        //if data present
                        if !(data.isEmpty) {
                            self.xCoordinate = data[0]["xcoordinate"].doubleValue
                            self.yCoordinate = data[0]["ycoordinate"].doubleValue
                            
                            DispatchQueue.main.async { [weak self] in
                                guard let strongSelf = self else { return }
                                strongSelf.mapButton.isEnabled = true
                                strongSelf.performSegue(withIdentifier: "show map", sender: self)
                            }
                        }
                    }
            }
        } else {
            let alert = UIAlertController(title: "Uh Oh", message: Text.networkFail, preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(ok)
            present(alert, animated: true, completion: nil)
        }
        mapButton.isEnabled = true
    }
    
    //MARK: - Navigation
    //********************************************************
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        if segue.identifier == "show map" {
            //let nc = segue.destinationViewController as! UINavigationController
            //let vc = nc.topViewController as! GoogleMapsViewController
            let vc = segue.destination as! GoogleMapsViewController
            vc.xCoordinate = self.xCoordinate
            vc.yCoordinate = self.yCoordinate
            vc.locationName = self.artist.getLocation()
        }
    }
}


//MARK: - UIScrollView delegate
//********************************************************
extension MusicDetailsViewController: UIScrollViewDelegate {
    
    /**
     Change the frame when scrolling - for stretchy header
     */
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
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
extension MusicDetailsViewController: EKEventEditViewDelegate {
    
    /**
     Dismiss the "add event" presentation.
     */
    func eventEditViewController(_ controller: EKEventEditViewController,
        didCompleteWith action: EKEventEditViewAction){
            self.dismiss(animated: true, completion: nil)
    }
}



