//
//  ColorKernel.swift
//  ProgSConCompanion
//
//  Created by Simon Gladman on 19/04/2016.
//  Copyright © 2016 Simon Gladman. All rights reserved.
//

import UIKit
import CoreImage

class ColorKernel: UIViewController
{
  let imageView = OpenGLImageView()
  
  override func viewDidLoad()
  {
    super.viewDidLoad()
    
    view.backgroundColor = UIColor.blackColor()
    
    view.addSubview(imageView)
    
    let monalisa = CIImage(image: UIImage(named: "monalisa.jpg")!)!
    
    let filter = ShadedTileFilter()
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

class ShadedTileFilter: CIFilter
{
  var inputImage: CIImage?
  
  let shadedTileKernel = CIColorKernel(
    string: "kernel vec4 shadedTile(__sample pixel)" +
    "{" +
    "  vec2 coord = samplerCoord(pixel);" +
    "  float brightness = mod(coord.y, 80.0) / 80.0;" +
    "  brightness *= 1.0 - mod(coord.x, 80.0) / 80.0;" +
    "  return vec4(sqrt(brightness) * pixel.rgb, pixel.a); " +
  "}")
  
  override var outputImage: CIImage!
  {
    guard let inputImage = inputImage,
      shadedTileKernel = shadedTileKernel else
    {
      return nil
    }
    
    let extent = inputImage.extent
    let arguments = [inputImage]
    
    return shadedTileKernel.applyWithExtent(extent, arguments: arguments)
  }
}