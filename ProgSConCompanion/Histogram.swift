//
//  ViewController.swift
//  vImageDemo
//
//  Created by Simon Gladman on 18/04/2016.
//  Copyright © 2016 Simon Gladman. All rights reserved.
//

import UIKit
import Accelerate

class Histogram: UIViewController
{
  var stack:UIStackView!
  
  let srcImageView = UIImageView()
  let targteImageView = UIImageView()
  let fianlImageView = UIImageView()
  
  override func viewDidLoad()
  {
    super.viewDidLoad()
    
    srcImageView.contentMode = .ScaleAspectFit
    targteImageView.contentMode = .ScaleAspectFit
    fianlImageView.contentMode = .ScaleAspectFit
    
    stack = UIStackView(arrangedSubviews: [srcImageView, targteImageView, fianlImageView])
    
    stack.distribution = .FillEqually
    stack.spacing = 20
    
    stack.frame = view.bounds.insetBy(dx: 20, dy: 20)
    view.addSubview(stack)
    
    let monalisa = UIImage(named: "monalisa.jpg")!
    let bluesky = UIImage(named: "bluesky.jpg")!
    
    let histogram = histogramCalculation(bluesky.CGImage!)
    
    let colored = histogramSpecification(monalisa.CGImage!, histogram: histogram)
    
    srcImageView.image = bluesky
    targteImageView.image = monalisa
    fianlImageView.image = colored
  }
  
  func histogramCalculation(imageRef: CGImage) -> (alpha: [UInt], red: [UInt], green: [UInt], blue: [UInt])
  {
    var inBuffer = vImage_Buffer()
    
    vImageBuffer_InitWithCGImage(
      &inBuffer,
      &format,
      nil,
      imageRef,
      UInt32(kvImageNoFlags))
    
    let alpha = [UInt](count: 256, repeatedValue: 0)
    let red = [UInt](count: 256, repeatedValue: 0)
    let green = [UInt](count: 256, repeatedValue: 0)
    let blue = [UInt](count: 256, repeatedValue: 0)
    
    let alphaPtr = UnsafeMutablePointer<vImagePixelCount>(alpha)
    let redPtr = UnsafeMutablePointer<vImagePixelCount>(red)
    let greenPtr = UnsafeMutablePointer<vImagePixelCount>(green)
    let bluePtr = UnsafeMutablePointer<vImagePixelCount>(blue)
    
    let rgba = [alphaPtr, redPtr, greenPtr, bluePtr]
    
    let histogram = UnsafeMutablePointer<UnsafeMutablePointer<vImagePixelCount>>(rgba)
    
    vImageHistogramCalculation_ARGB8888(&inBuffer, histogram, UInt32(kvImageNoFlags))
    
    return (alpha, red, green, blue)
  }
  
  func histogramSpecification(imageRef: CGImage, histogram: (alpha: [UInt], red: [UInt], green: [UInt], blue: [UInt])) -> UIImage
  {
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
    
    let alphaPtr = UnsafePointer<vImagePixelCount>(histogram.alpha)
    let redPtr = UnsafePointer<vImagePixelCount>(histogram.red)
    let greenPtr = UnsafePointer<vImagePixelCount>(histogram.green)
    let bluePtr = UnsafePointer<vImagePixelCount>(histogram.blue)
    
    let rgba = UnsafeMutablePointer<UnsafePointer<vImagePixelCount>>([alphaPtr, redPtr, greenPtr, bluePtr])
    
    vImageHistogramSpecification_ARGB8888(&imageBuffers.inBuffer, &imageBuffers.outBuffer, rgba, UInt32(kvImageNoFlags))
    
    let outImage = UIImage(fromvImageOutBuffer: imageBuffers.outBuffer)
    
    free(imageBuffers.pixelBuffer)
    
    return outImage!
  }
  
}

