//
//  AppDelegate.swift
//  ProgSConCompanion
//
//  Created by Simon Gladman on 19/04/2016.
//  Copyright © 2016 Simon Gladman. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?
  
  
  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool
  {
    application.statusBarStyle = UIStatusBarStyle.LightContent
    
    let tabbar = UITabBarController()
    
    let histogram = Histogram()
    histogram.tabBarItem.title = "Histogram"
    // complexGrid.tabBarItem.image = icon
    
    let dilation = Dilation()
    dilation.tabBarItem.title = "Dilation"

    tabbar.viewControllers = [histogram, dilation]
    
    window?.backgroundColor = UIColor.whiteColor()
    
    window?.rootViewController = tabbar
    window?.makeKeyAndVisible()
    
    return true
  }
}


