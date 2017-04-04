//
//  CustomAlertViewController.swift
//  Custom Alert
//
//  Created by Gavi Rawson on 1/16/16.
//  Copyright © 2016 Gavi Rawson. All rights reserved.
//

import UIKit

open class CustomAlertViewController: UIViewController, CustomAlertDelegate {
    
    open var alert = CustomAlertView()
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        alert.delegate = self
        alert.present()
    }
    
    /**
     Always keep the alert centered on the screen.
     */
    override open func viewWillLayoutSubviews() {
        alert.recenter()
    }
    
    /**
     Remove the view controller and view fron the parent.
     */
    open func alertWasDismissed() {
        self.view.removeFromSuperview()
        self.removeFromParentViewController()
    }
    
}


