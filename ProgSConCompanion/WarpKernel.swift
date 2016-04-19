//
//  WarpKernel.swift
//  ProgSConCompanion
//
//  Created by Simon Gladman on 19/04/2016.
//  Copyright © 2016 Simon Gladman. All rights reserved.
//

import UIKit
import CoreImage

class WarpKernel: UIViewController
{
  let imageView = OpenGLImageView()
  
  override func viewDidLoad()
  {
    super.viewDidLoad()
    
    view.backgroundColor = UIColor.blackColor()
    
    view.addSubview(imageView)
    
    let monalisa = CIImage(image: UIImage(named: "monalisa.jpg")!)!
    
    let filter = CarnivalMirror()
    filter.inputImage = monalisa
    
    imageView.image = filter.outputImage!
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



class CarnivalMirror: CIFilter
{
  var inputImage : CIImage?
  
  var inputHorizontalWavelength: CGFloat = 10
  var inputHorizontalAmount: CGFloat = 20
  
  var inputVerticalWavelength: CGFloat = 10
  var inputVerticalAmount: CGFloat = 20
  
  let carnivalMirrorKernel = CIWarpKernel(string:
    "kernel vec2 carnivalMirror(float xWavelength, float xAmount, float yWavelength, float yAmount)" +
      "{" +
      "   float y = destCoord().y + sin(destCoord().y / yWavelength) * yAmount; " +
      "   float x = destCoord().x + sin(destCoord().x / xWavelength) * xAmount; " +
      "   return vec2(x, y); " +
    "}"
  )
  
  override var outputImage : CIImage!
  {
    if let inputImage = inputImage,
      kernel = carnivalMirrorKernel
    {
      let arguments = [
        inputHorizontalWavelength, inputHorizontalAmount,
        inputVerticalWavelength, inputVerticalAmount]
      
      let extent = inputImage.extent
      
      return kernel.applyWithExtent(
        extent,
        roiCallback:
        {
          (index, rect) in
          return rect
        },
        inputImage: inputImage,
        arguments: arguments)
    }
    return nil
  }
}