//
//  AppDelegate.swift
//  Spring Fair
//
//  Created by Gavi Rawson on 11/22/15.
//  Copyright © 2015 Graws Inc. All rights reserved.
//

import UIKit
import GoogleMaps

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

        GMSServices.provideAPIKey(Keys.googleKey)
        
        UINavigationBar.appearance().barTintColor = Style.color1        //UIBar color
        UINavigationBar.appearance().translucent = false
        UINavigationBar.appearance().setBackgroundImage(                //Blend nav bar with background
            UIImage(),
            forBarPosition: .Any,
            barMetrics: .Default)
        UINavigationBar.appearance().shadowImage = UIImage()
        UINavigationBar.appearance().tintColor = UIColor.whiteColor()   //UIBar Tint Color
        UINavigationBar.appearance().barStyle = .Black                  //white status bar
        UINavigationBar.appearance().titleTextAttributes = [            //title bar font
            NSFontAttributeName: UIFont(name: "Blenda Script", size: 20)!
        ]
        
        UITabBar.appearance().tintColor = Style.color1
        
        let font = UIFont(name: "Open Sans Condensed", size: 16)
        UIBarButtonItem.appearance().setTitleTextAttributes([NSFontAttributeName: font!], forState: .Normal)

        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

