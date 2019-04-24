//
//  MarkerInfo.swift
//  TravelTracker
//
//  Created by Gabriel Blaine Palmer on 4/12/19.
//  Copyright © 2019 Gabriel Blaine Palmer. All rights reserved.
//

import Foundation
import FirebaseFirestore

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
    
    init?(id: String, firebaseDict: Dictionary<String, Any>) {
        self.id = id
        
        guard let xCoord = firebaseDict["xCoord"] as? Double,
            let yCoord = firebaseDict["yCoord"] as? Double,
            let date = firebaseDict["date"] as? Timestamp else { return nil }
        
        self.date = date.dateValue()
        self.xCoord = Float(xCoord)
        self.yCoord = Float(yCoord)
        comment = firebaseDict["comment"] as? String
        
    }
    
}
