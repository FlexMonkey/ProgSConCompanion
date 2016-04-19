//
//  AccelerateSupport.swift
//  ProgSConCompanion
//
//  Created by Simon Gladman on 19/04/2016.
//  Copyright © 2016 Simon Gladman. All rights reserved.
//

import UIKit
import Accelerate

typealias ImageBuffers = (inBuffer: vImage_Buffer, outBuffer: vImage_Buffer, pixelBuffer: UnsafeMutablePointer<Void>)

let bitmapInfo:CGBitmapInfo = CGBitmapInfo(
  rawValue: CGImageAlphaInfo.Last.rawValue)

var format = vImage_CGImageFormat(
  bitsPerComponent: 8,
  bitsPerPixel: 32,
  colorSpace: nil,
  bitmapInfo: bitmapInfo,
  version: 0,
  decode: nil,
  renderingIntent: .RenderingIntentDefault)

extension UIImage
{
  convenience init?(fromvImageOutBuffer outBuffer:vImage_Buffer)
  {
    var mutableBuffer = outBuffer
    var error = vImage_Error()
    
    let cgImage = vImageCreateCGImageFromBuffer(
      &mutableBuffer,
      &format,
      nil,
      nil,
      UInt32(kvImageNoFlags),
      &error)
    
    self.init(CGImage: cgImage.takeRetainedValue())
  }
}

// http://stackoverflow.com/questions/27092354/rotating-uiimage-in-swift

extension UIImage {
  public func imageRotatedByDegrees(degrees: CGFloat, flip: Bool) -> UIImage {
    
    let degreesToRadians: (CGFloat) -> CGFloat = {
      return $0 / 180.0 * CGFloat(M_PI)
    }
    
    // calculate the size of the rotated view's containing box for our drawing space
    let rotatedViewBox = UIView(frame: CGRect(origin: CGPointZero, size: size))
    let t = CGAffineTransformMakeRotation(degreesToRadians(degrees));
    rotatedViewBox.transform = t
    let rotatedSize = rotatedViewBox.frame.size
    
    // Create the bitmap context
    UIGraphicsBeginImageContext(rotatedSize)
    let bitmap = UIGraphicsGetCurrentContext()
    
    // Move the origin to the middle of the image so we will rotate and scale around the center.
    CGContextTranslateCTM(bitmap, rotatedSize.width / 2.0, rotatedSize.height / 2.0);
    
    //   // Rotate the image context
    CGContextRotateCTM(bitmap, degreesToRadians(degrees));
    
    // Now, draw the rotated/scaled image into the context
    var yFlip: CGFloat
    
    if(flip){
      yFlip = CGFloat(-1.0)
    } else {
      yFlip = CGFloat(1.0)
    }
    
    CGContextScaleCTM(bitmap, yFlip, -1.0)
    CGContextDrawImage(bitmap, CGRectMake(-size.width / 2, -size.height / 2, size.width, size.height), CGImage)
    
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return newImage
  }
}