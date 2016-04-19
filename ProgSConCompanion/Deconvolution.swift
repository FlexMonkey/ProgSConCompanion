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
  
  let cicontext = CIContext()

  func deConvolve(imageRef: CGImage) -> UIImage
  {
    let kernel = [Int16](count: 15 * 15, repeatedValue: 1)
    
    
    let kernelSide = UInt32(sqrt(Float(kernel.count)))
    
    let divisor: Int32 = 256
    let iterationCount: UInt32 = 8
    
    
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
    view.addSubview(imageView)
    imageView.contentMode = .ScaleAspectFit
    
    let source = UIImage(named: "building.jpg")!
    
    let blurred = CIImage(image: source)!
      .imageByApplyingFilter("CIBoxBlur", withInputParameters: [kCIInputRadiusKey: 15])
      .imageByCroppingToRect(CGRect(origin: CGPointZero, size: source.size).insetBy(dx: 15, dy: 15))
    
    let image = UIImage(CGImage: cicontext.createCGImage(blurred, fromRect: blurred.extent))
    
    let final = deConvolve(image.CGImage!)
    
    imageView.animationImages = [image, final]
    
    imageView.animationDuration = 2.0
    imageView.startAnimating()
  }
  
  override func viewDidLayoutSubviews()
  {
    imageView.frame = view.bounds.insetBy(dx: 50, dy: 50)
  }
  
}
