//
//  Equalization.swift
//  ProgSConCompanion
//
//  Created by Simon Gladman on 19/04/2016.
//  Copyright © 2016 Simon Gladman. All rights reserved.
//

import UIKit
import Accelerate

class HistogramEqualization: UIViewController
{
  var stack:UIStackView!
  
  let srcImageView = UIImageView()
  let targetImageView = UIImageView()

  override func viewDidLoad()
  {
    super.viewDidLoad()
    
    srcImageView.contentMode = .ScaleAspectFit
    targetImageView.contentMode = .ScaleAspectFit
    
    stack = UIStackView(arrangedSubviews: [srcImageView, targetImageView])
    
    stack.axis = .Vertical
    stack.distribution = .FillEqually
    stack.spacing = 20
    
    stack.frame = view.bounds.insetBy(dx: 20, dy: 20)
    view.addSubview(stack)
    
    let klImage = UIImage(named: "kl.jpg")!
    
    srcImageView.image = klImage
    targetImageView.image = equalizationFilter(klImage.CGImage!)
  }

  func equalizationFilter(imageRef: CGImage) -> UIImage
  {
    view.backgroundColor = UIColor.blackColor()
    
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
    
    vImageEqualization_ARGB8888(
      &inBuffer,
      &outBuffer,
      UInt32(kvImageNoFlags))

    let outImage = UIImage(fromvImageOutBuffer: outBuffer)
    
    free(pixelBuffer)
    
    return outImage!
  }
  
  override func preferredStatusBarStyle() -> UIStatusBarStyle
  {
    return .LightContent
  }
  
}
