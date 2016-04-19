//
//  Deconvolution.swift
//  ProgSConCompanion
//
//  Created by Simon Gladman on 19/04/2016.
//  Copyright © 2016 Simon Gladman. All rights reserved.
//

import UIKit
import Accelerate

class Deconvolution: UIViewController
{
  var imageView = UIImageView()
  var activityView = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
  
  
  let cicontext = CIContext()

  func deConvolve(imageRef: CGImage) -> UIImage
  {
    let kernel = [Int16](count: 15 * 15, repeatedValue: 1)
    
    
    let kernelSide = UInt32(sqrt(Float(kernel.count)))
    
    let divisor: Int32 = 256
    let iterationCount: UInt32 = 64
    
    
    var inBuffer = vImage_Buffer()
    
    vImageBuffer_InitWithCGImage(
      &inBuffer,
      &format,
      nil,
      imageRef,
      UInt32(kvImageNoFlags))
    
    let pixelBuffer = malloc(CGImageGetBytesPerRow(imageRef) * CGImageGetHeight(imageRef))
    
    let outBuffer = vImage_Buffer(
      data: pixelBuffer,
      height: UInt(CGImageGetHeight(imageRef)),
      width: UInt(CGImageGetWidth(imageRef)),
      rowBytes: CGImageGetBytesPerRow(imageRef))
    
    var imageBuffers = ImageBuffers(inBuffer: inBuffer, outBuffer: outBuffer, pixelBuffer: pixelBuffer)
    
    vImageRichardsonLucyDeConvolve_ARGB8888(
      &imageBuffers.inBuffer,
      &imageBuffers.outBuffer,
      nil,
      0,
      0,
      kernel,
      nil,
      kernelSide,
      kernelSide,
      0,
      0,
      divisor,
      0,
      [0,0,0,0],
      iterationCount,
      UInt32(kvImageNoFlags))
    
    let outImage = UIImage(fromvImageOutBuffer: imageBuffers.outBuffer)
    
    free(imageBuffers.pixelBuffer)
    
    return outImage!
  }

  override func viewDidLoad()
  {
    view.backgroundColor = UIColor.blackColor()
    
    view.addSubview(imageView)
    view.addSubview(activityView)
    
    imageView.contentMode = .ScaleAspectFit
    activityView.startAnimating()
    
    let source = UIImage(named: "building.jpg")!
    
    let blurred = CIImage(image: source)!
      .imageByApplyingFilter("CIBoxBlur", withInputParameters: [kCIInputRadiusKey: 15])
      .imageByCroppingToRect(CGRect(origin: CGPointZero, size: source.size).insetBy(dx: 15, dy: 15))
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0))
    {
      let image = UIImage(CGImage: self.cicontext.createCGImage(blurred, fromRect: blurred.extent))
      
      let final = self.deConvolve(image.CGImage!)
      
      dispatch_async(dispatch_get_main_queue())
      {
        self.imageView.animationImages = [image, final]
        
        self.imageView.animationDuration = 2.0
        self.imageView.startAnimating()
        
        self.activityView.stopAnimating()
      }
    }
  }
  
  override func viewDidLayoutSubviews()
  {
    imageView.frame = view.bounds.insetBy(dx: 50, dy: 50)
    activityView.frame = view.bounds
  }
  
  override func preferredStatusBarStyle() -> UIStatusBarStyle
  {
    return .LightContent
  }
  
}
