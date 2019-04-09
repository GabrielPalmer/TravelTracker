//
//  Point.swift
//  TravelTracker
//
//  Created by Gabriel Blaine Palmer on 4/7/19.
//  Copyright © 2019 Gabriel Blaine Palmer. All rights reserved.
//

import Foundation

class Marker {
    
    let date: Date
    let xCoord: Float
    let yCoord: Float
    var image: UIImage?
    var comment: String?
    
    init(xCoord: Float, yCoord: Float) {
        date = Date()
        self.xCoord = xCoord
        self.yCoord = yCoord
    }
}
