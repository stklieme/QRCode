//
//  main.swift
//  QRCode
//
//  Created by Stefan Klieme on 15.10.14.
//  Copyright (c) 2014 Stefan Klieme. All rights reserved.
//

import Foundation
import Cocoa

func generateQRImage(from string: String, errorCorrection: String, sideLength: Int) -> CGImage?
{
    let data = string.data( using: .isoLatin1)
    let filter = CIFilter(name:"CIQRCodeGenerator")!
    filter.setDefaults()
    filter.setValue(data, forKey:"inputMessage")
    filter.setValue(errorCorrection, forKey:"inputCorrectionLevel")
    let image = filter.outputImage
    
    let extent = image!.extent.integral
    let scale = CGFloat(sideLength) / extent.width
    let colorspace = CGColorSpaceCreateDeviceGray()
    let alphaMask = CGImageAlphaInfo.none.rawValue
    let bitmapRef = CGContext(data: nil, width: sideLength, height: sideLength, bitsPerComponent: 8, bytesPerRow: 4 * sideLength, space: colorspace, bitmapInfo: alphaMask)
    let context = CIContext(cgContext:bitmapRef!, options:nil)
    
    let bitmapImage = context.createCGImage(image!, from:extent)
    
    bitmapRef!.interpolationQuality = .none
    bitmapRef?.scaleBy(x: scale, y: scale)
    bitmapRef?.draw(bitmapImage!, in: extent)
    return bitmapRef?.makeImage()
}

var error = false

if CommandLine.arguments.contains("-help") {
    error = true
}

let userDefaults = UserDefaults.standard

var size = 0
var input = ""

if !error {
    if let sideLength  = Int(userDefaults.string(forKey: "s")!) {
        size = sideLength
    } else {
        size = 100
    }
    
    if let inputString = userDefaults.string(forKey: "i") {
        input = inputString
    } else {
        error = true
    }
}

var output = ""

if !error {
    if let outputPath = userDefaults.string(forKey: "o") {
        output = outputPath
    } else {
        error = true
    }
}

if error {
    print("usage: QRCode -i -o [-s -t [jpg|jpeg|tif|tiff|png|bmp|gif] -e [L|M|Q|H] ]")
    print("\t-i <input>\t\t\tthe string to be encoded")
    print("\t-o <output>\t\t\tthe destination image file path");
    print("\t-s <size>\t\t\tthe image side length in Pixel (optional; default = 100)")
    print("\t-t <type>\t\t\tthe image type (optional jpg/jpeg, tif/tiff, png, bmp, gif; default = png)")
    print("\t-e <error correction> the error correction format (optional L[=7%], M[=15%], Q[=25%], H[=30%] : default = M)")
    print("\t-help\t\t\t\tPrint this help message")
    exit(1)
} else {
    var fileExtension = "png"
    var imageType = kUTTypePNG
    
    if var type = userDefaults.string(forKey: "t") {
        
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
    if let correction = userDefaults.string(forKey: "e") {
        if ["L", "Q", "H"].contains(correction) {
            errorCorrection = correction
        }
    }
    
    let destinationURL = URL(fileURLWithPath:output).deletingPathExtension().appendingPathExtension(fileExtension)
    if let image = generateQRImage(from: input, errorCorrection: errorCorrection, sideLength: size) {
        
        if let destination = CGImageDestinationCreateWithURL(destinationURL as CFURL, imageType, 1, nil) {
            CGImageDestinationAddImage(destination, image, nil);
            if CGImageDestinationFinalize(destination) {
                exit(EXIT_SUCCESS)
            }
        }
    }
    
    print("QR image could not be created")
    exit(EXIT_FAILURE)
}




