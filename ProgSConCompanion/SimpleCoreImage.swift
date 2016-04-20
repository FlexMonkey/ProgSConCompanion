//
//  SimpleCoreImage.swift
//  ProgSConCompanion
//
//  Created by Simon Gladman on 20/04/2016.
//  Copyright © 2016 Simon Gladman. All rights reserved.
//

import CoreImage
import UIKit

class SimpleCoreImage: UIViewController
{
  let imageView = UIImageView()
  let context = CIContext()
  let bruges = UIImage(named: "bruges.jpg")!
  
  
  override func viewDidLoad()
  {
    view.backgroundColor = UIColor.blackColor()
    view.addSubview(imageView)
    
    let image = CIImage(image: bruges)!
    
    let noise = CIFilter(name: "CIRandomGenerator")?.outputImage?
      .imageByCroppingToRect(image.extent)
    
    let filteredImage = image
      .imageByApplyingFilter("CIVignette", withInputParameters: [kCIInputIntensityKey: 4])
      .imageByApplyingFilter("CIDarkenBlendMode", withInputParameters: [kCIInputBackgroundImageKey: noise!])
      .imageByApplyingFilter("CIColorControls", withInputParameters: [kCIInputSaturationKey: 0.25, kCIInputContrastKey: 1.15])
      .imageByApplyingFilter("CISepiaTone", withInputParameters: nil)
    

    let finalImage = context.createCGImage(filteredImage, fromRect: filteredImage.extent)
    
    imageView.animationImages = [bruges, UIImage(CGImage: finalImage)]
    
    imageView.animationDuration = 2.0
    imageView.startAnimating()
  }
  
  override func viewDidLayoutSubviews()
  {
    imageView.frame = view.bounds.insetBy(dx: 50, dy: 60)
  }
  
  override func preferredStatusBarStyle() -> UIStatusBarStyle
  {
    return .LightContent
  }
}
