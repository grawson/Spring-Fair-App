//
//  GoogleMapsViewController.swift
//  Spring Fair
//
//  Created by Gavi Rawson on 12/25/15.
//  Copyright © 2015 Graws Inc. All rights reserved.
//


import UIKit
import GoogleMaps
import GRCustomAlert

//TODO: Press directions when location services not enabled crashes app


class GoogleMapsViewController: UIViewController, GMSMapViewDelegate {
        
    //MARK: - Outlets
    //********************************************************
    
    @IBAction func getDirections(_ sender: UIBarButtonItem) {
        
        //check if location services enabled
        if CLLocationManager.locationServicesEnabled() {
            switch(CLLocationManager.authorizationStatus()) {
                case .notDetermined, .restricted, .denied:
                    locationDeniedAlert()
                case .authorizedAlways, .authorizedWhenInUse:
                    self.directions()
            }
        } else {
            locationDeniedAlert()
        }
    }
    
    //MARK: - Variables
    //********************************************************
    
    fileprivate var mapView: GMSMapView?
    var locationName = ""
    var xCoordinate = 0.0
    var yCoordinate = 0.0
    
    //MARK: - Life cycle
    //********************************************************
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.mapView?.delegate = self

        setupMap()
        setupEventMarker()
        
        //hide tab bar if present
        self.tabBarController?.tabBar.isHidden = true
    }
    
    //MARK: - Prvate methods
    //********************************************************
    
    /**
     Setup Google Maps view
     */
    fileprivate func setupMap() {
        let camera = GMSCameraPosition.camera(withLatitude: self.xCoordinate, longitude: self.yCoordinate, zoom: 17.5)
        self.mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        self.mapView?.isMyLocationEnabled = true
        self.mapView?.settings.compassButton = true
        self.mapView?.settings.myLocationButton = true
        self.mapView?.settings.scrollGestures = true
        self.mapView?.settings.zoomGestures = true
        self.mapView?.settings.rotateGestures = true
        self.mapView?.settings.tiltGestures = true
        self.view = mapView
    }
    
    /**
     Setup the marker on the map for the event.
     */
    fileprivate func setupEventMarker() {
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2DMake(self.xCoordinate, self.yCoordinate)
        marker.title = self.locationName
        //marker.snippet = "Australia"
        //marker.infoWindowAnchor = CGPointMake(0.5, 0.5)
        //marker.icon = GMSMarker.markerImageWithColor(Style.color1)
        //marker.appearAnimation = kGMSMarkerAnimationPop
        marker.map = mapView
    }
    
    /**
     Zoom on the map to a specific target
     
     - parameter x: x coordinate of the target
     - parameter y: y coordinate of the target
     */
    fileprivate func zoomTarget(_ x: CLLocationDegrees, y: CLLocationDegrees) {
        let target = CLLocationCoordinate2DMake(x, y)
        let cam = GMSCameraUpdate.setTarget(target)
        self.mapView?.animate(with: cam)
    }
    
    /**
     Segue to Google maps app to display directions to the event.
     */
    fileprivate func directions() {
        if let map = self.mapView {
            let url = "comgooglemaps://?saddr=\(map.myLocation?.coordinate.latitude),\(map.myLocation?.coordinate.longitude)&daddr=\(self.xCoordinate),\(self.yCoordinate)&center=37.423725,-122.0877&directionsmode=walking&zoom=17.5"
            
            //open directions in GM app if downloaded on system
            if (UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!)) {
                UIApplication.shared.openURL(URL(string: url)!)
            } else {
                let vc = CustomAlertViewController()
                vc.alert.titleText = "Uh Oh..."
                vc.alert.messageText = Text.networkFail
                self.addChildViewController(vc)
                self.view.addSubview(vc.view)
            }
        }
    }
    
    fileprivate func locationDeniedAlert() {
        let vc = CustomAlertViewController()
        vc.alert.titleText = Text.accessFailureTitle
        vc.alert.messageText = Text.locationFailureMessage
        self.addChildViewController(vc)
        self.view.addSubview(vc.view)
    }
}






