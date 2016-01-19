//
//  CustomAlertViewController.swift
//  Custom Alert
//
//  Created by Gavi Rawson on 1/16/16.
//  Copyright © 2016 Gavi Rawson. All rights reserved.
//

import UIKit

class CustomAlertViewController: UIViewController, CustomAlertDelegate {

    var alert = CustomAlertView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        alert.parentView = view   //set the parentView for a size reference
        alert.delegate = self
        alert.present()
    }
    
    /**
     Always keep the alert centered on the screen.
     */
    override func viewWillLayoutSubviews() {
        alert.recenter(view)
    }
    
    /**
     Remove the view controller and view fron the parent.
     */
    func alertWasDismissed() {
        self.view.removeFromSuperview()
        self.removeFromParentViewController()
    }
    
}
