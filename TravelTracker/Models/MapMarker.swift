//
//  Point.swift
//  TravelTracker
//
//  Created by Gabriel Blaine Palmer on 4/7/19.
//  Copyright © 2019 Gabriel Blaine Palmer. All rights reserved.
//

import Foundation

class MapMarker {
    
    let info: MarkerInfo
    var screenMarker: MaplyScreenMarker
    var component: MaplyComponentObject?
    var user: User?
    
    init(info: MarkerInfo) {
        self.info = info
        self.screenMarker = MaplyScreenMarker()
    }
    
    func printMarker() {
        print("id \(info.id)\n comment \(info.comment ?? "nil")\n xCoord \(info.xCoord)\n yCoord \(info.yCoord)")
    }
}
