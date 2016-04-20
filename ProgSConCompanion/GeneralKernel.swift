//
//  GeneralKernel.swift
//  ProgSConCompanion
//
//  Created by Simon Gladman on 19/04/2016.
//  Copyright © 2016 Simon Gladman. All rights reserved.
//

import UIKit
import CoreImage

class GeneralKernel: UIViewController
{
  var stack:UIStackView!
  
  let sourceImageView = OpenGLImageView()
  let maskImageView = OpenGLImageView()
  let finalImageView = OpenGLImageView()
  
  override func viewDidLoad()
  {
    super.viewDidLoad()
    
    view.backgroundColor = UIColor.blackColor()
    
    stack = UIStackView(arrangedSubviews: [sourceImageView, maskImageView, finalImageView])
    
    stack.distribution = .FillEqually
    stack.spacing = 20
    
    stack.frame = view.bounds.insetBy(dx: 20, dy: 20)
    view.addSubview(stack)
    
    let monalisa = CIImage(image: UIImage(named: "monalisa.jpg")!)!
    
    let gradientImage = CIFilter(
      name: "CIRadialGradient",
      withInputParameters: [
        kCIInputCenterKey:
          CIVector(x: 310, y: 390),
        "inputRadius0": 100,
        "inputRadius1": 300,
        "inputColor0":
          CIColor(red: 0, green: 0, blue: 0),
        "inputColor1":
          CIColor(red: 1, green: 1, blue: 1)
      ])?
      .outputImage?
      .imageByCroppingToRect(
        monalisa.extent)
    
    sourceImageView.image = monalisa
    maskImageView.image = gradientImage
    
    let filter = MaskedVariableBlur()
    filter.inputImage = monalisa
    filter.inputBlurMask = gradientImage
    
    finalImageView.image = filter.outputImage!
  }
  
  override func preferredStatusBarStyle() -> UIStatusBarStyle
  {
    return .LightContent
  }
}

class MaskedVariableBlur: CIFilter
{
  var inputImage: CIImage?
  var inputBlurMask: CIImage?
  var inputBlurRadius: CGFloat = 25
  
let maskedVariableBlur = CIKernel(string:
  "kernel vec4 lumaVariableBlur(sampler image, sampler blurImage, float blurRadius) " +
    "{ " +
    "   vec2 d = destCoord(); " +
    "    vec3 blurPixel = sample(blurImage, samplerCoord(blurImage)).rgb; " +
    "    float blurAmount = dot(blurPixel, vec3(0.2126, 0.7152, 0.0722)); " +
    "    float n = 0.0; " +
    "    int radius = int(blurAmount * blurRadius); " +
    "    vec3 accumulator = vec3(0.0, 0.0, 0.0); " +
    "    for (int x = -radius; x <= radius; x++) " +
    "    { " +
    "        for (int y = -radius; y <= radius; y++) " +
    "        { " +
    "            vec2 workingSpaceCoordinate = d + vec2(x,y); " +
    "            vec2 imageSpaceCoordinate = samplerTransform(image, workingSpaceCoordinate); " +
    "            vec3 color = sample(image, imageSpaceCoordinate).rgb; " +
    "            accumulator += color; " +
    "            n += 1.0; " +
    "        } " +
    "    } " +
    "    accumulator /= n; " +
    "    return vec4(accumulator, 1.0); " +
  "} "
)
  
  override var outputImage: CIImage!
  {
    guard let inputImage = inputImage, inputBlurMask = inputBlurMask else
    {
      return nil
    }
    
    let extent = inputImage.extent

    let blur = maskedVariableBlur?.applyWithExtent(
      inputImage.extent,
      roiCallback:
      {
        (index, rect) in
        return rect
      },
      arguments: [inputImage, inputBlurMask, inputBlurRadius])
    
    return blur!.imageByCroppingToRect(extent)
  }
}

