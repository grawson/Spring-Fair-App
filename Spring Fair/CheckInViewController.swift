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


class CheckInViewController: UIViewController {

    //MARK: - Const
    //********************************************************
    
    fileprivate struct Constants {
        static let eventsPicker = 1
        static let groupsPicker = 2
        static let pickerPlaceholder = "Click to Select"
        static let submitTitle = "Submit"
        static let errorMessage = "error_message"
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
            guard let slf = self,
                  let row = slf.selectedPickerRow
            else { return }
            
            // Set event details
            let event = slf.events[row]
            sender.setTitle(event.name, for: .normal)
            slf.dateLabel.text = event.dateToString()
            slf.timeLabel.text = event.timeToString()
            slf.locationLabel.text = event.location
            
            slf.selectedPickerRow = nil // reset var
            slf.enableSubmit()
            if slf.eventDetailsStack.isHidden { slf.animateEventDetails = true }
        }
        present(picker, animated: true, completion: nil)
    }
    
    @IBAction func groupSelected(_ sender: UIButton!) {
        let picker = createPicker(pickerTag: Constants.groupsPicker) { [weak self] in
            guard let slf = self, let row = slf.selectedPickerRow else { return }            
            let group = slf.groups[row]
            sender.setTitle(group.name, for: .normal)
            slf.selectedPickerRow = nil // reset var
            slf.enableSubmit()
        }
        present(picker, animated: true, completion: nil)
    }

    @IBAction func submitPressed(_ sender: UIButton) {
        checkIn()
    }
    
    
    //MARK: - Var
    //********************************************************
    
    var animateEventDetails = false { didSet { if animateEventDetails { view.setNeedsLayout() } } }
    var eventSelected = false, groupSelected = false, emailEntered = false
    var events = [CheckInEvent]()
    var groups = [Group]()
    var selectedPickerRow: Int?

    
    //MARK: - Life Cycle
    //********************************************************

    override func viewDidLoad() {
        
        
        // SW Reveal controller
        open.target = self.revealViewController()
        open.action = #selector(SWRevealViewController.revealToggle(_:))
        self.revealViewController().view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        self.revealViewController().delegate = self
        self.revealViewController().panGestureRecognizer()
        
//        // Check internet connection
//        if !Reachability.isConnectedToNetwork() {
//            let alert = UIAlertController(title: "Uh Oh", message: "Where's your internet connection?", preferredStyle: .alert)
//            let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
//            alert.addAction(ok)
//            present(alert, animated: true, completion: nil)
//        }
//        
//        // infinite loop until connects
//        while !Reachability.isConnectedToNetwork() { }
        loadEvents()
        loadGroups()
    }
    
    override func viewWillLayoutSubviews() {
        if animateEventDetails {
            UIView.animate(withDuration: 0.3) { [weak self] in
                guard let slf = self else { return }
                slf.eventDetailsStack.isHidden = !slf.eventSelected
            }
            animateEventDetails = false
        }
    }
    
    
    //MARK: - Functions
    //********************************************************
    
    
    // enable the submit button if fields have been entered
    fileprivate func enableSubmit() {
        submitButton.isEnabled = eventSelected && groupSelected && emailEntered
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
        emailField.text = ""
        eventSelected = false; groupSelected = false; emailEntered = false;
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
    
    private func checkIn() {
        
        // UI activity indicator
        submitButton.setTitle("", for: .normal)
        submitActivity.startAnimating()
       
        // params
        let deviceUUID: String = (UIDevice.current.identifierForVendor?.uuidString)!
        let parameters: [String: String] = [
            "event": "\(eventButton.titleLabel?.text ?? "")",
            "group": "\(groupButton.titleLabel?.text ?? "")",
            "name" : "\(emailField.text ?? "")",
            "device_id" : "\(deviceUUID)"
        ]
        
        // request
        Alamofire.request(Requests.checkIn, method: .post, parameters: parameters).responseJSON { [weak self] response in
            guard let slf = self else { return }
            if let jsonResult = response.result.value {
                let json = JSON(jsonResult)
                
                var title = ""; var message = "";
                if json[Constants.errorMessage].stringValue == "" {
                    title = "Congrats!"
                    message = "You've Successfully checked in!"
                } else {
                    title = "Uh Oh"
                    message = "You've already checked into this event for your group!"
                }
                
                DispatchQueue.main.async {
                    
                    // UI activity
                    slf.submitButton.setTitle(Constants.submitTitle, for: .normal)
                    slf.submitActivity.stopAnimating()
                    
                    // alert
                    let alert = UIAlertController( title: title, message: message, preferredStyle: .alert)
                    let ok = UIAlertAction(title: "OK", style: .default, handler: { (ok) in
                        slf.clearForm()
                    })
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
        selectedPickerRow = row
        switch pickerView.tag {
        case Constants.eventsPicker: eventSelected = true;
        case Constants.groupsPicker: groupSelected = true;
        default: break
        }
    }
}


//MARK: - text field controller delegate
//********************************************************
extension CheckInViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        emailEntered = textField.text != nil && textField.text != ""
        enableSubmit()
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        emailEntered = false
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
