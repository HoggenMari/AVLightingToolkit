//
//  ImageUtils.swift
//  AVLightingToolkit
//
//  Created by Marius Hoggenmüller on 19.12.18.
//  Copyright © 2018 Marius Hoggenmüller. All rights reserved.
//

import Foundation
import UIKit

class ImageUtils {
    
    static func getImageFilename(for info: [UIImagePickerController.InfoKey : Any]) -> String? {
        if let asset = info[UIImagePickerController.InfoKey.imageURL] as? URL {
            return asset.lastPathComponent
        } else {
            return nil
        }
    }
    
    static func saveImageToDocumentPath(for info: [UIImagePickerController.InfoKey : Any]) {
        
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage{
            
            guard let filename = getImageFilename(for: info) else {
                return
            }
            let fileURL = URL.documentsDirectory.appendingPathComponent(filename)
            
            if !FileManager.default.fileExists(atPath: fileURL.path) {
                do {
                    try editedImage.pngData()!.write(to: fileURL)
                    print("Image Added Successfully")
                } catch {
                    print(error)
                }
            } else {
                print("Image Not Added")
            }
        }
    }
    
    static func getImageFromDocumentPath(for filename: String) -> UIImage? {
        
        let path = URL.urlInDocumentsDirectory(with: filename).path
        let image = UIImage(contentsOfFile: path)
        return image
    }
}

extension URL {
    static var documentsDirectory: URL {
        let documentsDirectoryURL = try! FileManager().url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        return documentsDirectoryURL
    }
    
    static func urlInDocumentsDirectory(with filename: String) -> URL {
        return documentsDirectory.appendingPathComponent(filename)
    }
}
