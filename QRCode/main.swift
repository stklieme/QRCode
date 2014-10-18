//
//  main.swift
//  QRCode
//
//  Created by Stefan Klieme on 15.10.14.
//  Copyright (c) 2014 Stefan Klieme. All rights reserved.
//

import Foundation
import Cocoa

func generateQRImageFromString(string: String, sideLength:CGFloat) -> CGImage?
{
    let data = string.dataUsingEncoding(NSUTF8StringEncoding)
    let filter = CIFilter(name:"CIQRCodeGenerator")
    filter.setDefaults()
    filter.setValue(data, forKey:"inputMessage")
    let image = filter.outputImage
    
    let extent = CGRectIntegral(image.extent())
    let scale = min(sideLength / CGRectGetWidth(extent), sideLength / CGRectGetHeight(extent));
    let width = CGRectGetWidth(extent) * scale;
    let height = CGRectGetHeight(extent) * scale;
    let colorspace = CGColorSpaceCreateDeviceRGB()
    let alphaMask = CGBitmapInfo(rawValue:CGImageAlphaInfo.PremultipliedFirst.rawValue)
    let bitmapRef = CGBitmapContextCreate(nil, UInt(width), UInt(height), 8, 4 * UInt(sideLength), colorspace, alphaMask)
    let context = CIContext(CGContext:bitmapRef, options:nil)
    
    let bitmapImage = context.createCGImage(image, fromRect:extent)
    
    CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone)
    CGContextScaleCTM(bitmapRef, scale, scale)
    CGContextDrawImage(bitmapRef, extent, bitmapImage)
    return CGBitmapContextCreateImage(bitmapRef)
}

var error = false

if contains(Process.arguments, "-help") {
    error = true
}

let userDefaults = NSUserDefaults.standardUserDefaults()

var size : CGFloat!
var input : String!
if !error {
    if let sideLength  = userDefaults.stringForKey("s")?.toInt() {
        size = CGFloat(sideLength)
    } else {
        size = 100.0
    }
    
    if let inputString = userDefaults.stringForKey("i") {
        input = inputString
    } else {
        error = true
    }
}

var output : String!
if !error {
    if let outputPath = userDefaults.stringForKey("o") {
        output = outputPath
    } else {
        error = true
    }
}

if error {
    println("usage: QRCode -i -o [-s -t]")
    println("\t-i <input>\t\tthe string to be encoded")
    println("\t-o <output>\t\tthe destination image file path");
    println("\t-s <size>\t\tthe image side length in Pixel (optional; default = 100)")
    println("\t-t <type>\t\tthe image type (optional jpg/jpeg, tif/tiff, png, bmp, gif; default = png)")
    println("\t-help\t\t\tPrint this help message")
    exit(1)
} else {
    var fileExtension : String!
    var imageType : String!
    
    if let type = userDefaults.stringForKey("t") {
        fileExtension = type
        
        switch type {
        case "jpg", "jpeg":
            imageType = kUTTypeJPEG
        case "tiff", "tif":
            imageType = kUTTypeTIFF
        case "bmp":
            imageType = kUTTypeBMP
        case "gif":
            imageType = kUTTypeGIF
            
        default:
            imageType = kUTTypePNG
            fileExtension = "png"
        }
    } else {
        imageType = kUTTypePNG
        fileExtension = "png"
    }

    if let path = output.stringByDeletingPathExtension.stringByAppendingPathExtension(fileExtension) {
        if let image = generateQRImageFromString(input, size) {
            
            if let URL = NSURL(fileURLWithPath:path) {
                let destination : CGImageDestinationRef = CGImageDestinationCreateWithURL(URL, imageType, 1, nil)
                CGImageDestinationAddImage(destination, image, nil);
                if CGImageDestinationFinalize(destination) {
                    exit(0)
                }
            }
        }
    }
}
println("QR image could not be created")
exit(1)




