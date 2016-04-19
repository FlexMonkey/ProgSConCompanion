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
    view.backgroundColor = UIColor.blackColor()
    
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
  
  override func preferredStatusBarStyle() -> UIStatusBarStyle
  {
    return .LightContent
  }
}


