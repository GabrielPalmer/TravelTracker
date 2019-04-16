//
//  OtherExtensions.swift
//  TravelTracker
//
//  Created by Gabriel Blaine Palmer on 4/1/19.
//  Copyright © 2019 Gabriel Blaine Palmer. All rights reserved.
//

import Foundation
import UIKit


extension UIButton {
    
    private func image(withColor color: UIColor) -> UIImage? {
        let rect = CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        
        context?.setFillColor(color.cgColor)
        context?.fill(rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
    
    func setBackgroundColor(_ color: UIColor, for state: UIControl.State) {
        self.setBackgroundImage(image(withColor: color), for: state)
    }
}

enum ImageEncodingQuality: CGFloat {
    case png = 0
    case jpegLow = 0.2
    case jpegMid = 0.5
    case jpegHigh = 0.75
}

extension KeyedEncodingContainer {
    
    mutating func encode(_ value: UIImage,
                         forKey key: KeyedEncodingContainer.Key,
                         quality: ImageEncodingQuality = .png) throws {
        var imageData: Data!
        if quality == .png {
            imageData = value.pngData()
        } else {
            imageData = value.jpegData(compressionQuality: quality.rawValue)
        }
        try encode(imageData, forKey: key)
    }
    
}

extension KeyedDecodingContainer {
    
    public func decode(_ type: UIImage.Type, forKey key: KeyedDecodingContainer.Key) -> UIImage? {
        do {
            let imageData = try decode(Data.self, forKey: key)
            if let image = UIImage(data: imageData) {
                return image
            } else {
                return nil
            }
        } catch {
            return nil
        }
        
    }
    
}
