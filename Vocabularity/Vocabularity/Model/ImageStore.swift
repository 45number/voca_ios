//
//  ImageStore.swift
//  Vocabularity
//
//  Created by Admin on 28.09.2018.
//  Copyright © 2018 vocabularity. All rights reserved.
//

import UIKit

struct ImageStore {
    
    static func delete(imageNamed name: String) {
        guard let imagePath = ImageStore.path(for: name) else {
            return
        }
        
        try? FileManager.default.removeItem(at: imagePath)
    }
    
    static func retrieve(imageNamed name: String) -> UIImage? {
        guard let imagePath = ImageStore.path(for: name) else {
            return nil
        }
        
        return UIImage(contentsOfFile: imagePath.path)
    }
    
    static func store(image: UIImage, name: String) throws {
        
        guard let imageData = UIImagePNGRepresentation(image) else {
            throw NSError(domain: "com.thecodedself.imagestore", code: 0, userInfo: [NSLocalizedDescriptionKey: "The image could not be created"])
        }
        
        guard let imagePath = ImageStore.path(for: name) else {
            throw NSError(domain: "com.thecodedself.imagestore", code: 0, userInfo: [NSLocalizedDescriptionKey: "The image path could not be retrieved"])
        }
        
        try imageData.write(to: imagePath)
    }
    
    private static func path(for imageName: String, fileExtension: String = "png") -> URL? {
        let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        return directory?.appendingPathComponent("\(imageName).\(fileExtension)")
    }
    
    
    static func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    static func generateImageName(length: Int) -> String {
        
        let timeStamp = String(UInt64((NSDate().timeIntervalSince1970 + 62_135_596_800) * 10_000_000))
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let len = UInt32(letters.length)
        
        var randomString = ""
        
        for _ in 0 ..< length {
            let rand = arc4random_uniform(len)
            var nextChar = letters.character(at: Int(rand))
            randomString += NSString(characters: &nextChar, length: 1) as String
        }
        
        let imageName = "v_\(randomString)_\(timeStamp)"
        return imageName
    }
    
}
