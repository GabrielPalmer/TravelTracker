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

extension UIColor {
    static func random() -> UIColor {
        return UIColor(red: (CGFloat(arc4random()) / CGFloat(UInt32.max)), green: (CGFloat(arc4random()) / CGFloat(UInt32.max)), blue: (CGFloat(arc4random()) / CGFloat(UInt32.max)), alpha: 1)
    }
}

