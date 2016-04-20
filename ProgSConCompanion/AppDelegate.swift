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
    
    let icon = UIImage(CIImage: CIImage(color: CIColor(red: 1, green: 0, blue: 0)).imageByCroppingToRect(CGRect(x: 0, y: 0, width: 30, height: 30)))
    
    let simple = SimpleCoreImage()
    simple.tabBarItem.title = "Core Image"
    simple.tabBarItem.image = icon
    
    let colorKernel = ColorKernel()
    colorKernel.tabBarItem.title = "Color Kernel"
    colorKernel.tabBarItem.image = icon
    
    let warpKernel = WarpKernel()
    warpKernel.tabBarItem.title = "Warp Kernel"
    warpKernel.tabBarItem.image = icon
    
    let generalKernel = GeneralKernel()
    generalKernel.tabBarItem.title = "General Kernel"
    generalKernel.tabBarItem.image = icon
    
    let histogram = Histogram()
    histogram.tabBarItem.title = "Histogram"
    histogram.tabBarItem.image = icon
    
    let dilation = Dilation()
    dilation.tabBarItem.title = "Dilation"
    dilation.tabBarItem.image = icon
    
    let deconvolution = Deconvolution()
    deconvolution.tabBarItem.title = "Deconvolution"
    deconvolution.tabBarItem.image = icon
    
    let metalPerformanceShaders = MetalPerformanceShadersDemo()
    metalPerformanceShaders.tabBarItem.title = "MPS"
    metalPerformanceShaders.tabBarItem.image = icon
    
    let equalization = HistogramEqualization()
    equalization.tabBarItem.title = "Equalization"
    equalization.tabBarItem.image = icon

    tabbar.viewControllers = [simple, colorKernel, warpKernel, generalKernel, histogram, dilation, equalization, deconvolution, metalPerformanceShaders]
    
    window?.backgroundColor = UIColor.whiteColor()
    
    window?.rootViewController = tabbar
    window?.makeKeyAndVisible()
    
    return true
  }
}


