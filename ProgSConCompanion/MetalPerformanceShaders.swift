//
//  MetalPerformanceShaders.swift
//  ProgSConCompanion
//
//  Created by Simon Gladman on 19/04/2016.
//  Copyright © 2016 Simon Gladman. All rights reserved.
//

import UIKit

#if !arch(i386) && !arch(x86_64)
  
import MetalPerformanceShaders
import MetalKit

let sourceImage = UIImage(named: "telescope.jpg")!

class MetalPerformanceShadersDemo: UIViewController, MTKViewDelegate
{
  let imageView = MTKView()
  let device = MTLCreateSystemDefaultDevice()!
  
  var value: Float = 1
  
  private var frameStartTime = CFAbsoluteTimeGetCurrent()
  private var frameNumber = 0
  
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
    
    imageView.contentScaleFactor = 1
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
      return
    }
    
    guard let currentDrawable = imageView.currentDrawable where imageView.frame.size != CGSizeZero else
    {
      return
    }
    
    frameNumber += 1
    
    if frameNumber == 100
    {
      let frametime = (CFAbsoluteTimeGetCurrent() - frameStartTime) / 100
      print (String(format: "%.1f fps", 1 / frametime))
      frameStartTime = CFAbsoluteTimeGetCurrent()
      frameNumber = 0
    }
    
    value += 0.025
    
    let intermediateTextureDesciptor = MTLTextureDescriptor.texture2DDescriptorWithPixelFormat(
      MTLPixelFormat.RGBA8Unorm,
      width: imageTexture.width,
      height: imageTexture.height,
      mipmapped: false)
    
    let intermediateTexture = device.newTextureWithDescriptor(intermediateTextureDesciptor)
    
    let scale = MPSImageLanczosScale(device: device)
    
    var tx = MPSScaleTransform(
      scaleX: 1,
      scaleY: -1,
      translateX: 0,
      translateY: Double(-imageTexture.height))
    
    withUnsafePointer(&tx)
    {
      scale.scaleTransform = $0
    }
    
    let blur = MPSImageGaussianBlur(
      device: device,
      sigma: abs(sin(value)) * 200)
    
    // ----
    
    let commandQueue = device.newCommandQueue()
    
    let commandBuffer = commandQueue.commandBuffer()

    scale.encodeToCommandBuffer(
      commandBuffer,
      sourceTexture: imageTexture,
      destinationTexture: intermediateTexture)
    
    blur.encodeToCommandBuffer(
      commandBuffer,
      sourceTexture: intermediateTexture,
      destinationTexture: currentDrawable.texture)
    
    commandBuffer.presentDrawable(imageView.currentDrawable!)
    
    commandBuffer.commit();
  }
  
  override func viewDidLayoutSubviews()
  {
    imageView.frame = CGRect(
      x: view.frame.midX - sourceImage.size.width / 2,
      y: view.frame.midY - sourceImage.size.height / 2,
      width: sourceImage.size.width,
      height: sourceImage.size.height)
  }
  
  override func preferredStatusBarStyle() -> UIStatusBarStyle
  {
    return .LightContent
  }
}

#else

  class MetalPerformanceShadersDemo: UIViewController
  {
    let label = UILabel()
    
    override func viewDidLoad()
    {
      view.backgroundColor = UIColor.blackColor()
      
      label.textAlignment = .Center
      label.textColor = UIColor.yellowColor()
      label.font = UIFont.boldSystemFontOfSize(36)
      label.text = "Not available in simulator"
      
      view.addSubview(label)
    }
    
    override func viewDidLayoutSubviews()
    {
      label.frame = view.bounds
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle
    {
      return .LightContent
    }

  }

 #endif


