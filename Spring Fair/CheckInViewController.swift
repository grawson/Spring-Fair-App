//
//  CheckInViewController.swift
//  Spring Fair
//
//  Created by Guest User on 4/3/17.
//  Copyright © 2017 Graws Inc. All rights reserved.
//

import UIKit


class CheckInViewController: UIViewController {

    //MARK: - Outlets
    //********************************************************
    
    @IBOutlet weak var eventButton: UIButton!
    @IBOutlet weak var open: UIBarButtonItem!
    @IBOutlet weak var step1Stack: UIStackView!
    @IBOutlet weak var eventDetailsStack: UIStackView!
    @IBOutlet weak var submitButton: UIButton! {
        didSet {
            submitButton.roundCorners([.topLeft , .bottomLeft, .topRight, .bottomRight], radius: Style.smallestRounded)
        }
    }
    
    //MARK: - Actions
    //********************************************************
    
    
    @IBAction func eventSelected(_ sender: UIButton!) {
        toggleEventDetails()
        
        let alertView = UIAlertController(title: "", message: "\n\n\n\n\n\n\n", preferredStyle: .alert)
        let pickerView = UIPickerView(frame: CGRect(x: 0, y: -10, width: 250, height: 180))
        pickerView.dataSource = self
        pickerView.delegate = self
        alertView.view.addSubview(pickerView)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertView.addAction(action)
        present(alertView, animated: true, completion: nil)
    }
    
    
    //MARK: - Var
    //********************************************************
    
    var eventDetailsHidden = true
    var eventSelected = false, groupSelected = false, emailEntered = false
    let events = ["event1", "event2", "event3", "event4"]
    
    
    //MARK: - Life Cycle
    //********************************************************

    override func viewDidLoad() {
        
        //bar button
        open.target = self.revealViewController()
        open.action = #selector(SWRevealViewController.revealToggle(_:))
        
        //opens slide menu with gesture
        self.revealViewController().view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        
        // Needed for disabling user interaction when menu is open */
        self.revealViewController().delegate = self
        self.revealViewController().panGestureRecognizer()
        
        enableSubmit()
    }
    
    override func viewWillLayoutSubviews() {
        UIView.animate(withDuration: 0.3) { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.eventDetailsStack.isHidden = strongSelf.eventDetailsHidden
        }
    }
    
    
    //MARK: - Functions
    //********************************************************
    
    private func toggleEventDetails() {
        eventDetailsHidden = !eventDetailsHidden
        view.setNeedsLayout()
    }
    
    private func enableSubmit() {
        submitButton.isEnabled = eventSelected && groupSelected && emailEntered
        submitButton.backgroundColor = submitButton.isEnabled ? Style.color1 : UIColor.groupTableViewBackground
    }

}

extension CheckInViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int { return 1 }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int { return events.count }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? { return events[row] }
}

extension CheckInViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        eventButton.setTitle(events[row], for: .normal)
        eventSelected = true
    }
}


//MARK: - SWReveal controller delegate
//********************************************************
extension CheckInViewController: SWRevealViewControllerDelegate {
    
    /**
     Needed for disabling user interaction when menu is open
     */
    func revealController(_ revealController: SWRevealViewController, willMoveTo position: FrontViewPosition){
        view.isUserInteractionEnabled = (position == FrontViewPosition.left)
    }
}
