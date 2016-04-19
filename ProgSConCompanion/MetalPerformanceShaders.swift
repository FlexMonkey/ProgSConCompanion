//
//  MetalPerformanceShaders.swift
//  ProgSConCompanion
//
//  Created by Simon Gladman on 19/04/2016.
//  Copyright © 2016 Simon Gladman. All rights reserved.
//

import UIKit
import MetalPerformanceShaders
import MetalKit

let sourceImage = UIImage(named: "telescope.jpg")!.imageRotatedByDegrees(180, flip: false)

class MetalPerformanceShadersDemo: UIViewController, MTKViewDelegate
{
  let imageView = MTKView()
  let device = MTLCreateSystemDefaultDevice()!
  
  var frameNumber: Float = 1
  
  let imageTexture: MTLTexture =
  {
    let textureLoader = MTKTextureLoader(device: MTLCreateSystemDefaultDevice()!)
    let imageTexture:MTLTexture
  
    do
    {
      imageTexture = try textureLoader.newTextureWithCGImage(sourceImage.CGImage!, options: nil)
    }
    catch
    {
      fatalError("unable to create texture from image")
    }
    
    return imageTexture
  }()
  
  override func viewDidLoad()
  {
    imageView.device = device
    imageView.delegate = self

    view.addSubview(imageView)
    
    imageView.framebufferOnly = false
  }
  
  // MTKViewDelegate
  
  func mtkView(view: MTKView, drawableSizeWillChange size: CGSize)
  {
    
  }
  
  func drawInMTKView(view: MTKView)
  {
    if imageView.frame.size == CGSizeZero
    {
      print("UGH!!")
      return
    }
    
    guard let currentDrawable = imageView.currentDrawable where imageView.frame.size != CGSizeZero else
    {
      return
    }
    
    frameNumber += 0.05
    
    let blur = MPSImageGaussianBlur(device: device, sigma: abs(sin(frameNumber)) * 200)
    
    let commandQueue = device.newCommandQueue()
    
    let commandBuffer = commandQueue.commandBuffer()
    
    blur.encodeToCommandBuffer(
      commandBuffer,
      sourceTexture: imageTexture,
      destinationTexture: currentDrawable.texture)
    
    commandBuffer.presentDrawable(imageView.currentDrawable!)
    
    commandBuffer.commit();
  }
  
  override func viewDidLayoutSubviews()
  {
    imageView.frame = CGRect(
      x: view.frame.midX - sourceImage.size.width / 4,
      y: view.frame.midY - sourceImage.size.height / 4,
      width: sourceImage.size.width / 2,
      height: sourceImage.size.height / 2)
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
