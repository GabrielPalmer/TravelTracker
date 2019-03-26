//
//  ViewController.swift
//  TravelTracker
//
//  Created by Gabriel Blaine Palmer on 3/25/19.
//  Copyright © 2019 Gabriel Blaine Palmer. All rights reserved.
//

import UIKit
import WhirlyGlobeMaplyComponent

class MapViewController: UIViewController {
    
    private var maplyVC: MaplyBaseViewController? //myViewC

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        maplyVC = WhirlyGlobeViewController()
//        view.addSubview(maplyVC!.view)
//        maplyVC!.view.frame = view.bounds
//        addChild(maplyVC!)
//
//        let globeVC = maplyVC as? WhirlyGlobeViewController
//
//        // we want a black background for a globe, a white background for a map.
//        maplyVC!.clearColor = (globeVC != nil) ? UIColor.black : UIColor.white
//
//        maplyVC!.frameInterval = 2
//
//        // set up the data source
//        if let tileSource = MaplyMBTileSource(mbTiles: "geography-class_medres"),
//            let layer = MaplyQuadImageTilesLayer(tileSource: tileSource) {
//            layer.handleEdges = (globeVC != nil)
//            layer.coverPoles = (globeVC != nil)
//            layer.requireElev = false
//            layer.waitLoad = false
//            layer.drawPriority = 0
//            layer.singleLevelLoading = false
//            maplyVC!.add(layer)
//        }
//
//        globeVC!.height = 0.8
//        globeVC!.animate(toPosition: MaplyCoordinateMakeWithDegrees(-3.6704803, 40.5023056), time: 1.0)
    
        
    }

}

