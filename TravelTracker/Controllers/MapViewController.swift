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
    
    var globeIsVisible: Bool = true
    
    @IBOutlet weak var testButton: UIButton!
    
    @IBAction func testButtonTapped(_ sender: Any) {
        if globeIsVisible {
            globeIsVisible = !globeIsVisible
            testButton.setTitle("Globe", for: .normal)
            testButton.setTitleColor(UIColor.white, for: .normal)
            testButton.backgroundColor = UIColor.gray.withAlphaComponent(0.8)
            globeVC!.view.isHidden = true
            mapVC!.view.isHidden = false
        } else if !globeIsVisible {
            globeIsVisible = !globeIsVisible
            testButton.setTitle("Map", for: .normal)
            testButton.setTitleColor(UIColor.white, for: .normal)
            testButton.backgroundColor = UIColor.gray.withAlphaComponent(0.8)
            mapVC!.view.isHidden = true
            globeVC!.view.isHidden = false
        }
    }
    
    private var globeVC: WhirlyGlobeViewController? //myViewC
    private var mapVC: MaplyViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        testButton.layer.cornerRadius = 5
        testButton.setTitle("Map", for: .normal)
        testButton.setTitleColor(UIColor.white, for: .normal)
        testButton.backgroundColor = UIColor.gray.withAlphaComponent(0.85)
        
        mapVC = MaplyViewController(mapType: .typeFlat)
        view.addSubview(mapVC!.view)
        mapVC!.view.frame = view.bounds
        addChild(mapVC!)
        mapVC!.view.isHidden = true
        mapVC!.rotateGesture = false
        
        globeVC = WhirlyGlobeViewController()
        view.addSubview(globeVC!.view)
        globeVC!.view.frame = view.bounds
        addChild(globeVC!)
        globeVC!.view.isHidden = false
        globeVC!.setZoomLimitsMin(0.000002, max: 1.5)
        
        // we want a black background for a globe, a white background for a map.
        globeVC!.clearColor = (globeVC != nil) ? UIColor.black : UIColor.white
        globeVC!.frameInterval = 3
        
        // set up the data source
        if let tileSource = MaplyMBTileSource(mbTiles: "geography-class_medres"),
            let layer = MaplyQuadImageTilesLayer(tileSource: tileSource) {
            layer.handleEdges = (globeVC != nil)
            layer.coverPoles = (globeVC != nil)
            layer.requireElev = false
            layer.waitLoad = false
            layer.drawPriority = 0
            layer.singleLevelLoading = false
            mapVC!.add(layer)
        }
        // mousebird.github.io/WhirlyGlobe/tutorial/ios/remote_image_layer.html
        let useLocalTiles = false
        let layer: MaplyQuadImageTilesLayer
        
        if useLocalTiles {
            guard let tileSource = MaplyMBTileSource(mbTiles: "geography-class_medres") else {
                print("can't load local tile set")
            }
            layer = MaplyQuadImageTilesLayer(tileSource: tileSource)!
        } else {
            let baseCacheDir = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)[0]
            let tilesCacheDir = "\(baseCacheDir)/stamentiles/"
            let maxZoom = Int32(18)
            
            guard let tileSource = MaplyRemoteTileSource(
                baseURL: "http://tile.stamen.com/terrain/",
                ext: "png",
                minZoom: 0,
                maxZoom: maxZoom) else {
                    print("can't create a remote tile source")
                    return
            }
            tileSource.cacheDir = tilesCacheDir
            layer = MaplyQuadImageTilesLayer(tileSource: tileSource)!
            globeVC!.add(layer)
        }
        
        /*
         if let tileSource = MaplyMBTileSource(mbTiles: "geography-class_medres"),
         let layer = MaplyQuadImageTilesLayer(tileSource: tileSource) {
         layer.handleEdges = (globeVC != nil)
         layer.coverPoles = (globeVC != nil)
         layer.requireElev = false
         layer.waitLoad = false
         layer.drawPriority = 0
         layer.singleLevelLoading = false
         globeVC!.add(layer)
         }
         */
        globeVC!.height = 0.8
        //globeVC!.animate(toPosition: MaplyCoordinateMakeWithDegrees(-3.6704803, 40.5023056), time: 1.0)
        
        mapVC!.height = 1
        mapVC!.animate(toPosition: MaplyCoordinateMakeWithDegrees(-3.6704803, 40.5023056), time: 1.0)
        
        view.bringSubviewToFront(testButton)
    }
    
}
