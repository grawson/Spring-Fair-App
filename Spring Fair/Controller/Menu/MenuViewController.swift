//
//  MenuViewController.swift
//  Spring Fair
//
//  Created by Gavi Rawson on 11/22/15.
//  Copyright © 2015 Graws Inc. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController {
    
    //MARK: - Outlets
    //********************************************************
    
    @IBOutlet weak var button1: UIButton!
    @IBOutlet weak var button2: UIButton!
    @IBOutlet weak var button3: UIButton!
    @IBOutlet weak var button4: UIButton!
    @IBOutlet weak var musicButton: UIButton!
    
    
    //MARK: - Life cycle
    //********************************************************
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Round corners of all buttons
        let buttons = [button1, button2, button3, button4, musicButton]
        for button in buttons {
            button?.layer.masksToBounds = true
            button?.layer.cornerRadius = Style.smallRounded
        }
    }
    
    //MARK: - methods
    //********************************************************

    /**
     Set white status bar.
     */
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
}



