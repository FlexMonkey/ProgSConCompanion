//
//  Dilation.swift
//  ProgSConCompanion
//
//  Created by Simon Gladman on 19/04/2016.
//  Copyright © 2016 Simon Gladman. All rights reserved.
//

import UIKit
import Accelerate

class Dilation: UIViewController
{
  var imageView = UIImageView()
  
  let cicontext = CIContext()

  let kernel: [UInt8] = [
    255, 255, 255, 255, 255, 255, 000, 255, 255, 255, 255, 255, 255,
    255, 255, 255, 255, 255, 255, 000, 255, 255, 255, 255, 255, 255,
    255, 255, 000, 255, 255, 255, 000, 255, 255, 255, 000, 255, 255,
    255, 255, 255, 000, 255, 255, 000, 255, 255, 000, 255, 255, 255,
    255, 255, 255, 255, 000, 255, 000, 255, 000, 255, 255, 255, 255,
    255, 255, 255, 255, 255, 000, 000, 000, 255, 255, 255, 255, 255,
    000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000,
    255, 255, 255, 255, 255, 000, 000, 000, 255, 255, 255, 255, 255,
    255, 255, 255, 255, 000, 255, 000, 255, 000, 255, 255, 255, 255,
    255, 255, 255, 000, 255, 255, 000, 255, 255, 000, 255, 255, 255,
    255, 255, 000, 255, 255, 255, 000, 255, 255, 255, 000, 255, 255,
    255, 255, 255, 255, 255, 255, 000, 255, 255, 255, 255, 255, 255,
    255, 255, 255, 255, 255, 255, 000, 255, 255, 255, 255, 255, 255]
  
  let thresholdKernel = CIColorKernel(
    string: "kernel vec4 thresholdFilter(__sample image, float threshold)" +
      "{" +
      "   float luma = dot(image.rgb, vec3(0.2126, 0.7152, 0.0722));" +
      
      "   return vec4(image.rgb, image.a * step(threshold, luma));" +
    "}")
  
  override func viewDidLoad()
  {
    view.backgroundColor = UIColor.blackColor()
    
    view.addSubview(imageView)
    imageView.contentMode = .ScaleAspectFit
    
    let image = UIImage(named: "stars.jpg")!
    
    let ciImage = CIImage(image: image)!
    let ciThreshold = thresholdKernel?.applyWithExtent(ciImage.extent, arguments: [ciImage, 0.75])
    
    let cgThreshold = cicontext.createCGImage(ciThreshold!, fromRect: ciThreshold!.extent)
    
    let stars = dilateFilter(cgThreshold, kernel: kernel)
    
    let ciComposite = ciImage.imageByApplyingFilter("CIAdditionCompositing", withInputParameters: [kCIInputBackgroundImageKey: CIImage(image: stars)!])
    let ciFinal = cicontext.createCGImage(ciComposite, fromRect: ciComposite.extent)
    
    imageView.animationImages = [image, UIImage(CGImage: ciFinal)]
    
    imageView.animationDuration = 2.0
    imageView.startAnimating()
  }
  
  func dilateFilter(imageRef: CGImage, kernel: [UInt8]) -> UIImage
  {
    let kernelSide = UInt32(sqrt(Float(kernel.count)))
    
    var inBuffer = vImage_Buffer()
    
    vImageBuffer_InitWithCGImage(
      &inBuffer,
      &format,
      nil,
      imageRef,
      UInt32(kvImageNoFlags))
    
    let pixelBuffer = malloc(CGImageGetBytesPerRow(imageRef) * CGImageGetHeight(imageRef))
    
    var outBuffer = vImage_Buffer(
      data: pixelBuffer,
      height: UInt(CGImageGetHeight(imageRef)),
      width: UInt(CGImageGetWidth(imageRef)),
      rowBytes: CGImageGetBytesPerRow(imageRef))

    vImageDilate_ARGB8888(
      &inBuffer,
      &outBuffer,
      0,
      0,
      kernel,
      UInt(kernelSide),
      UInt(kernelSide),
      UInt32(kvImageNoFlags))
    
    let outImage = UIImage(fromvImageOutBuffer: outBuffer)
    
    free(pixelBuffer)
    
    return outImage!
  }
  
  override func viewDidLayoutSubviews()
  {
    imageView.frame = view.bounds.insetBy(dx: 50, dy: 50)
  }
  
  override func preferredStatusBarStyle() -> UIStatusBarStyle
  {
    return .LightContent
  }
  
}
