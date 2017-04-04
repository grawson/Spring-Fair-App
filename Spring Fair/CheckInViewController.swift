//
//  CheckInViewController.swift
//  Spring Fair
//
//  Created by Guest User on 4/3/17.
//  Copyright © 2017 Graws Inc. All rights reserved.
//

import UIKit
import GRCustomAlert


class CheckInViewController: UIViewController {

    //MARK: - Const
    //********************************************************
    
    fileprivate struct Constants {
        static let eventsPicker = 1
        static let groupsPicker = 2
        static let pickerPlaceholder = "Click to Select"
    }
    
    //MARK: - Outlets
    //********************************************************
    
    @IBOutlet weak var emailField: UITextField! { didSet { emailField.delegate = self } }
    @IBOutlet weak var eventButton: UIButton!
    @IBOutlet weak var groupButton: UIButton!
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
            guard let slf = self else { return }
            guard let title = slf.selectedPickerItem else { return }
            sender.setTitle(title, for: .normal)
            slf.selectedPickerItem = nil
            slf.enableSubmit()
            if slf.eventDetailsStack.isHidden { slf.animateEventDetails = true }
        }
        present(picker, animated: true, completion: nil)
    }
    
    @IBAction func groupSelected(_ sender: UIButton!) {
        let picker = createPicker(pickerTag: Constants.groupsPicker) { [weak self] in
            guard let slf = self else { return }
            guard let title = slf.selectedPickerItem else { return }
            sender.setTitle(title, for: .normal)
            slf.selectedPickerItem = nil
            slf.enableSubmit()
        }
        present(picker, animated: true, completion: nil)
    }

    @IBAction func submitPressed(_ sender: UIButton) {
        if validate() {
            let alert = UIAlertController(
                title: "Congrats!", message: "You've successfully checked in!", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .default, handler: { [weak self] (ok) in
                guard let slf = self else { return }
                slf.clearForm()
            })
            alert.addAction(ok)
            present(alert, animated: true, completion: nil)
        }
    }
    
    
    //MARK: - Var
    //********************************************************
    
    var animateEventDetails = false { didSet { if animateEventDetails { view.setNeedsLayout() } } }
    var eventSelected = false, groupSelected = false, emailEntered = false
    let events = ["Event 1", "Event 2", "Event 3", "Event 4"]
    let groups = ["Group 1", "Group 2", "Group 3", "Group 4"]
    var selectedPickerItem: String?

    
    //MARK: - Life Cycle
    //********************************************************

    override func viewDidLoad() {
        
        // SW Reveal controller
        open.target = self.revealViewController()
        open.action = #selector(SWRevealViewController.revealToggle(_:))
        self.revealViewController().view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        self.revealViewController().delegate = self
        self.revealViewController().panGestureRecognizer()
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
    
    // Validate all fields before submitting
    private func validate() -> Bool {
        let success = isValidEmail(email: emailField.text ?? "")
        if !success {
            let vc = CustomAlertViewController()
            vc.alert.titleText = "Error"
            vc.alert.messageText = "Invalid Email"
            self.addChildViewController(vc)
            self.view.addSubview(vc.view)
        }
        return success
    }
    
    // validate email address
    private func isValidEmail(email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        let result = emailTest.evaluate(with: email)
        return result
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
        case Constants.eventsPicker: return events[row]
        case Constants.groupsPicker: return groups[row]
        default: return nil
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch pickerView.tag {
        case Constants.eventsPicker: selectedPickerItem = events[row]; eventSelected = true;
        case Constants.groupsPicker: selectedPickerItem = groups[row]; groupSelected = true;
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
