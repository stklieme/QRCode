//
//  main.swift
//  QRCode
//
//  Created by Stefan Klieme on 15.10.14.
//  Copyright (c) 2014 Stefan Klieme. All rights reserved.
//

import Foundation
import Cocoa

func generateQRImageFromString(string: String, errorCorrection: String, sideLength: Int) -> CGImage?
{
    let data = string.dataUsingEncoding( NSISOLatin1StringEncoding)
    let filter = CIFilter(name:"CIQRCodeGenerator")
    filter.setDefaults()
    filter.setValue(data, forKey:"inputMessage")
    filter.setValue(errorCorrection, forKey:"inputCorrectionLevel")
    let image = filter.outputImage
    
    let extent = CGRectIntegral(image.extent())
    let scale = CGFloat(sideLength) / CGRectGetWidth(extent)
    let colorspace = CGColorSpaceCreateDeviceGray()
    let alphaMask = CGBitmapInfo(rawValue:CGImageAlphaInfo.None.rawValue)
    let bitmapRef = CGBitmapContextCreate(nil, sideLength, sideLength, 8, 4 * sideLength, colorspace, alphaMask)
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

var size : Int!
var input : String!
if !error {
    if let sideLength  = userDefaults.stringForKey("s")?.toInt() {
        size = sideLength
    } else {
        size = 100
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
    println("usage: QRCode -i -o [-s -t [jpg|jpeg|tif|tiff|png|bmp|gif] -e [L|M|Q|H] ]")
    println("\t-i <input>\t\t\tthe string to be encoded")
    println("\t-o <output>\t\t\tthe destination image file path");
    println("\t-s <size>\t\t\tthe image side length in Pixel (optional; default = 100)")
    println("\t-t <type>\t\t\tthe image type (optional jpg/jpeg, tif/tiff, png, bmp, gif; default = png)")
    println("\t-e <error correction> the error correction format (optional L[=7%], M[=15%], Q[=25%], H[=30%] : default = M)")
    println("\t-help\t\t\t\tPrint this help message")
    exit(1)
} else {
    var fileExtension = "png"
    var imageType = kUTTypePNG
    
    if var type = userDefaults.stringForKey("t") {
        
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
            type = "png"
        }
        
        fileExtension = type
    }
    
    var errorCorrection = "M"
    if let correction = userDefaults.stringForKey("e") {
        if contains(["L", "Q", "H"], correction) {
            errorCorrection = correction
        }
    }

    if let path = output.stringByDeletingPathExtension.stringByAppendingPathExtension(fileExtension) {
        if let image = generateQRImageFromString(input, errorCorrection, size) {
            
            if let URL = NSURL(fileURLWithPath:path) {
                let destination = CGImageDestinationCreateWithURL(URL, imageType, 1, nil)
                CGImageDestinationAddImage(destination, image, nil);
                if CGImageDestinationFinalize(destination) {
                    exit(0)
                }
            }
        }
    }

    println("QR image could not be created")
    exit(1)
}




