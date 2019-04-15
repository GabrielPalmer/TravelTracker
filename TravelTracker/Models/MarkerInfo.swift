//
//  MarkerInfo.swift
//  TravelTracker
//
//  Created by Gabriel Blaine Palmer on 4/12/19.
//  Copyright © 2019 Gabriel Blaine Palmer. All rights reserved.
//

import Foundation

class MarkerInfo {
    
    let id: String
    let date: Date
    let xCoord: Float
    let yCoord: Float
    var image: UIImage?
    var comment: String?
    
    init(xCoord: Float, yCoord: Float) {
        date = Date()
        id = UUID().uuidString
        self.xCoord = xCoord
        self.yCoord = yCoord
    }
    
}
