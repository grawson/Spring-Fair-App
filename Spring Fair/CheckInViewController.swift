//
//  CheckInViewController.swift
//  Spring Fair
//
//  Created by Guest User on 4/3/17.
//  Copyright © 2017 Graws Inc. All rights reserved.
//

import UIKit
import GRCustomAlert
import Alamofire
import SwiftyJSON
import CoreLocation


class CheckInViewController: UIViewController {

    //MARK: - Const
    //********************************************************
    
    fileprivate struct Constants {
        static let eventsPicker = 1
        static let groupsPicker = 2
        static let pickerPlaceholder = "Click to Select"
        static let submitTitle = "Submit"
        static let errorMessage = "error_message"
        static let dist = 0.15
    }
    
    //MARK: - Outlets
    //********************************************************
    
    @IBOutlet weak var submitActivity: UIActivityIndicatorView! { didSet { submitActivity.stopAnimating() } }
    @IBOutlet weak var eventActivity: UIActivityIndicatorView! { didSet { eventActivity.startAnimating() } }
    @IBOutlet weak var groupActivity: UIActivityIndicatorView! { didSet { groupActivity.startAnimating() } }
    @IBOutlet weak var eventButton: UIButton! {
        didSet {
            eventButton.setTitle("", for: .disabled)
            eventButton.isEnabled = false
        }
    }
    @IBOutlet weak var groupButton: UIButton! {
        didSet {
            groupButton.setTitle("", for: .disabled)
            groupButton.isEnabled = false
        }
    }
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!

    @IBOutlet weak var nameField: UITextField! { didSet { nameField.delegate = self } }
    @IBOutlet weak var emailField: UITextField! { didSet { emailField.delegate = self } }
    @IBOutlet weak var open: UIBarButtonItem!
    @IBOutlet weak var step1Stack: UIStackView!
    @IBOutlet weak var eventDetailsStack: UIStackView! { didSet { eventDetailsStack.isHidden = true } }
    @IBOutlet weak var submitButton: UIButton! {
        didSet {
            submitButton.roundCorners([.topLeft , .bottomLeft, .topRight, .bottomRight], radius: Style.smallestRounded)
            enableSubmit()
        }
    }
    
    //MARK: - Actions
    //********************************************************
    
    
    @IBAction func eventSelected(_ sender: UIButton!) {
        let picker = createPicker(pickerTag: Constants.eventsPicker) { [weak self] in
            guard let slf = self, let event = slf.selectedEvent else { return }
            
            // Set event details
            sender.setTitle(event.name, for: .normal)
            slf.dateLabel.text = event.dateToString()
            slf.timeLabel.text = event.timeToString()
            slf.locationLabel.text = event.location
            
            slf.enableSubmit()
            if slf.eventDetailsStack.isHidden { slf.animateEventDetails = true }
        }
        present(picker, animated: true, completion: nil)
    }
    
    @IBAction func groupSelected(_ sender: UIButton!) {
        let picker = createPicker(pickerTag: Constants.groupsPicker) { [weak self] in
            guard let slf = self, let group = slf.selectedGroup else { return }
            sender.setTitle(group.name, for: .normal)
            slf.enableSubmit()
        }
        present(picker, animated: true, completion: nil)
    }

    @IBAction func submitPressed(_ sender: UIButton) {
        validateCheckIn()
        // once user location is determined, didSet method for userLocation method
        // will be called, and check in process will continue
    }
    
    
    //MARK: - Var
    //********************************************************
    
    var dist: Double?
    var animateEventDetails = false { didSet { if animateEventDetails { view.setNeedsLayout() } } }
    var events = [CheckInEvent]()
    var groups = [Group]()
    var selectedEvent: CheckInEvent?
    var selectedGroup: Group?
    var nameEntered = false
    var emailEntered = false
    var locationManager = CLLocationManager()
    var userLocation: CLLocationCoordinate2D? { didSet { if userLocation != nil { continueValidateCheckIn() } }}

    
    //MARK: - Life Cycle
    //********************************************************

    override func viewDidLoad() {
        
        
        // SW Reveal controller
        open.target = self.revealViewController()
        open.action = #selector(SWRevealViewController.revealToggle(_:))
        self.revealViewController().view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        self.revealViewController().delegate = self
        self.revealViewController().panGestureRecognizer()
        
        loadData()
        locationManager.requestWhenInUseAuthorization()
        
    }
    
    override func viewWillLayoutSubviews() {
        if animateEventDetails {
            UIView.animate(withDuration: 0.3) { [weak self] in
                guard let slf = self else { return }
                slf.eventDetailsStack.isHidden = slf.selectedEvent == nil
            }
            animateEventDetails = false
        }
    }
    
    
    //MARK: - Functions
    //********************************************************
    
    private func isValidEmail(testStr: String) -> Bool {
        let emailRegEx = "^(?:(?:(?:(?: )*(?:(?:(?:\\t| )*\\r\\n)?(?:\\t| )+))+(?: )*)|(?: )+)?(?:(?:(?:[-A-Za-z0-9!#$%&’*+/=?^_'{|}~]+(?:\\.[-A-Za-z0-9!#$%&’*+/=?^_'{|}~]+)*)|(?:\"(?:(?:(?:(?: )*(?:(?:[!#-Z^-~]|\\[|\\])|(?:\\\\(?:\\t|[ -~]))))+(?: )*)|(?: )+)\"))(?:@)(?:(?:(?:[A-Za-z0-9](?:[-A-Za-z0-9]{0,61}[A-Za-z0-9])?)(?:\\.[A-Za-z0-9](?:[-A-Za-z0-9]{0,61}[A-Za-z0-9])?)*)|(?:\\[(?:(?:(?:(?:(?:[0-9]|(?:[1-9][0-9])|(?:1[0-9][0-9])|(?:2[0-4][0-9])|(?:25[0-5]))\\.){3}(?:[0-9]|(?:[1-9][0-9])|(?:1[0-9][0-9])|(?:2[0-4][0-9])|(?:25[0-5]))))|(?:(?:(?: )*[!-Z^-~])*(?: )*)|(?:[Vv][0-9A-Fa-f]+\\.[-A-Za-z0-9._~!$&'()*+,;=:]+))\\])))(?:(?:(?:(?: )*(?:(?:(?:\\t| )*\\r\\n)?(?:\\t| )+))+(?: )*)|(?: )+)?$"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        let result = emailTest.evaluate(with: testStr)
        return result
    }
    
    private func loadData() {
        
        let connected = Reachability.isConnectedToNetwork()
        if !connected {
            let alert = UIAlertController(title: "Uh Oh", message: "Where's your internet connection?", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(ok)
            present(alert, animated: true, completion: nil)
        } else {
            loadEvents()
            loadGroups()
            loadConst()
        }
    }
    
    // enable the submit button if fields have been entered
    fileprivate func enableSubmit() {
        submitButton.isEnabled = selectedEvent != nil && selectedGroup != nil && nameEntered && emailEntered
        submitButton.backgroundColor = submitButton.isEnabled ? Style.color1 : UIColor.lightGray
    }
    
    // Create an alert view with an embedded picker
    private func createPicker(pickerTag: Int, handler: @escaping()->Void) -> UIAlertController {
        let alertView = UIAlertController(title: "", message: "\n\n\n\n\n\n\n", preferredStyle: .alert)
        let pickerView = UIPickerView(frame: CGRect(x: 0, y: -10, width: 250, height: 180))
        pickerView.tag = pickerTag
        pickerView.dataSource = self
        pickerView.delegate = self
        alertView.view.addSubview(pickerView)
        pickerView.delegate?.pickerView?(pickerView, didSelectRow: 0, inComponent: 0) // selects first row on appear
        let action = UIAlertAction(title: "Select", style: .default) { (self) in
            handler()
        }

        alertView.addAction(action)
        return alertView
    }
    
    // Clear the entire form
    private func clearForm() {
        eventButton.setTitle(Constants.pickerPlaceholder, for: .normal)
        animateEventDetails = true
        groupButton.setTitle(Constants.pickerPlaceholder, for: .normal)
        nameField.text = ""
        emailField.text = ""
        selectedEvent = nil; selectedGroup = nil; nameEntered = false; emailEntered = false
        enableSubmit()
    }
    
    private func loadEvents() {
        Alamofire.request(Requests.checkInEvents).responseJSON { [weak self] response in
            guard let slf = self else { return }
            if let jsonResult = response.result.value {
                let json = JSON(jsonResult)
                for (_, data) in json {
                    slf.events.append(CheckInEvent(data: data))
                }
                
                // enable/hide UI elements
                DispatchQueue.main.async { [weak self] in
                    guard let slf = self else { return }
                    slf.eventActivity.stopAnimating()
                    slf.eventButton.isEnabled = true
                }
            }
        }
    }
    
    private func loadGroups() {
        Alamofire.request(Requests.allGroups).responseJSON { [weak self] response in
            guard let slf = self else { return }
            if let jsonResult = response.result.value {
                let json = JSON(jsonResult)
                for (_, data) in json {
                    slf.groups.append(Group(data: data))
                }
                
                // enable/hide UI elements
                DispatchQueue.main.async { [weak self] in
                    guard let slf = self else { return }
                    slf.groupActivity.stopAnimating()
                    slf.groupButton.isEnabled = true
                }
            }
        }
    }
    
    private func loadConst() {
        Alamofire.request(Requests.dist).responseJSON { [weak self] response in
            guard let slf = self else { return }
            if let jsonResult = response.result.value {
                let json = JSON(jsonResult)
                slf.dist = json[0]["value"].doubleValue
            }
        }

    }
    
    func validateCheckIn() {
        guard let start = selectedEvent?.startTime, let end = selectedEvent?.endTime else { return }
        guard let email = emailField.text else { return }
        animateSubmit(animate: true)
        
        // validate email
        if !isValidEmail(testStr: email) {
            let alert = UIAlertController(title: "Uh Oh", message: "Invalid Email!", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(action)
            present(alert, animated: true, completion: nil)
            animateSubmit(animate: false)
            return
        }
        
        // validate time
        if !(start...end).contains(Date()) {
            let alert = UIAlertController(title: "Uh Oh", message: "The event isn't happening now!", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(action)
            present(alert, animated: true, completion: nil)
            animateSubmit(animate: false)
            return
        }
        
        // validate location
        if (CLLocationManager.locationServicesEnabled()) {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        } else {
            let alert = UIAlertController(title: "Uh Oh", message: Text.locationFailureMessage, preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(action)
            present(alert, animated: true, completion: nil)
            animateSubmit(animate: false)
            return
        }
    }
    
    func continueValidateCheckIn() {
        guard let event = selectedEvent else {
            userLocation = nil
            animateSubmit(animate: false)
            return
        }
        
        guard Reachability.isConnectedToNetwork() else {
            let alert = UIAlertController(title: "Uh Oh", message: Text.networkFail, preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(action)
            present(alert, animated: true, completion: nil)
            userLocation = nil
            animateSubmit(animate: false)
            return
        }
        
        //load coordinates
        let outData = ["name": event.formattedLocation() ?? ""]
        Alamofire.request(Requests.coordinates, method: .post, parameters: outData).responseJSON { [weak self] response in
            guard let slf = self else { return }
            if let json = response.result.value {
                let data = JSON(json)

                if !(data.isEmpty) {
                    let xCoordinate = data[0]["xcoordinate"].doubleValue
                    let yCoordinate = data[0]["ycoordinate"].doubleValue
                    
                    let coord = CLLocationCoordinate2D(latitude: xCoordinate, longitude: yCoordinate)
                    if slf.compareCoordinates(coord1: coord, coord2: slf.userLocation) {
                        DispatchQueue.main.async {
                            slf.checkIn()
                        }
                    } else {
                        let alert = UIAlertController(title: "Uh Oh", message: "You're in the wrong location!", preferredStyle: .alert)
                        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                        alert.addAction(action)
                        slf.present(alert, animated: true, completion: nil)
                        slf.userLocation = nil
                        DispatchQueue.main.async { slf.animateSubmit(animate: false) }
                        return
                    }
                }
            }
            slf.userLocation = nil
        }
     
    }
    
    private func degreesToRadians(degrees: Double) -> Double {
        return degrees * Double.pi / 180;
    }
            
    private func compareCoordinates(coord1: CLLocationCoordinate2D?, coord2: CLLocationCoordinate2D?) -> Bool {
        guard let coord1 = coord1, let coord2 = coord2 else { return false }

        let earthRadiusKm = 6371.0;
        
        let dLat = degreesToRadians(degrees: coord2.latitude - coord1.latitude);
        let dLon = degreesToRadians(degrees: coord2.longitude - coord1.longitude);
        
        let lat1 = degreesToRadians(degrees: coord1.latitude);
        let lat2 = degreesToRadians(degrees: coord2.latitude);
        
        let a = sin(dLat/2) * sin(dLat/2) + sin(dLon/2) * sin(dLon/2) * cos(lat1) * cos(lat2);
        let c = 2 * atan2(sqrt(a), sqrt(1-a));
        let miles = earthRadiusKm * c;
        
        return miles <= (dist ?? Constants.dist)
    }
    
    private func animateSubmit(animate: Bool) {
        if animate {
            submitButton.setTitle("", for: .normal)
            submitActivity.startAnimating()
        } else {
            submitButton.setTitle(Constants.submitTitle, for: .normal)
            submitActivity.stopAnimating()
        }
    }


    private func checkIn() {
       
        // params
        let deviceUUID: String = (UIDevice.current.identifierForVendor?.uuidString)!
        let parameters: [String: String] = [
            "event": "\(eventButton.titleLabel?.text ?? "")",
            "group": "\(groupButton.titleLabel?.text ?? "")",
            "name" : "\(nameField.text ?? "")",
            "email" : "\(emailField.text ?? "")",
            "device_id" : "\(deviceUUID)"
        ]
        
        // request
        Alamofire.request(Requests.checkIn, method: .post, parameters: parameters).responseJSON { [weak self] response in
            guard let slf = self else { return }
            if let jsonResult = response.result.value {
                let json = JSON(jsonResult)
                
                var title = ""; var message = "";
                var ok = UIAlertAction(title: "OK", style: .default, handler: { (ok) in
                    slf.clearForm()
                })
                if json[Constants.errorMessage].stringValue == "" {
                    title = "Congrats!"
                    message = "You've Successfully checked in!"
                } else {
                    title = "Uh Oh"
                    message = "You've already checked into this event for your group!"
                    ok = UIAlertAction(title: "OK", style: .default, handler: nil)
                }
                
                DispatchQueue.main.async {
                    
                    // UI activity
                    slf.animateSubmit(animate: false)
                    
                    // alert
                    let alert = UIAlertController( title: title, message: message, preferredStyle: .alert)
                  
                    alert.addAction(ok)
                    slf.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
}

//MARK: - Picker View Delegate/Data Source
//********************************************************
extension CheckInViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int { return 1 }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView.tag {
        case Constants.eventsPicker: return events.count
        case Constants.groupsPicker: return groups.count
        default: return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch pickerView.tag {
        case Constants.eventsPicker: return events[row].name
        case Constants.groupsPicker: return groups[row].name
        default: return nil
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch pickerView.tag {
        case Constants.eventsPicker: selectedEvent = events[row]
        case Constants.groupsPicker: selectedGroup = groups[row]
        default: break
        }
    }
}

//MARK: - Location delegate
//********************************************************
extension CheckInViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationManager.stopUpdatingLocation()
        if userLocation == nil { userLocation = manager.location?.coordinate }
    }
}

    

//MARK: - text field controller delegate
//********************************************************
extension CheckInViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        switch textField {
        case nameField: nameEntered = textField.text != nil && textField.text != ""
        case emailField: emailEntered = textField.text != nil && textField.text != ""
        default: break
        }
        enableSubmit()
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        switch textField {
        case nameField: nameEntered = false
        case emailField: emailEntered = false
        default: break
        }
        enableSubmit()
        return true
    }
    
}


//MARK: - SWReveal controller delegate
//********************************************************
extension CheckInViewController: SWRevealViewControllerDelegate {
    /** Needed for disabling user interaction when menu is open */
    func revealController(_ revealController: SWRevealViewController, willMoveTo position: FrontViewPosition){
        view.isUserInteractionEnabled = (position == FrontViewPosition.left)
    }
}
