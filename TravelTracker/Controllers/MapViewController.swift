//
//  ViewController.swift
//  TravelTracker
//
//  Created by Gabriel Blaine Palmer on 3/25/19.
//  Copyright © 2019 Gabriel Blaine Palmer. All rights reserved.
//

import UIKit
import WhirlyGlobeMaplyComponent
import CoreLocation

class MapViewController: UIViewController, MaplyLocationTrackerDelegate {
    
    //    // get location
    //    let locationManager = CLLocationManager()
    //    //
    var globeIsVisible: Bool = true
    
    var latitude: Float = 40.419774
    var longitude: Float = -111.885743
    
    @IBOutlet weak var displayView: UIView!
    
    @IBOutlet weak var toolbar: UIView!
    
    @IBOutlet weak var addPinButton: UIButton!
    
    
    
    @IBOutlet weak var addCommentButton: UIButton!
    
    @IBOutlet weak var addPictureButton: UIButton!
    
    @IBOutlet weak var friendsButton: UIButton!
    
    @IBAction func friendsButtonTapped(_ sender: Any) {
        performSegue(withIdentifier: "friendsSegue", sender: nil)
    }
    
    @IBOutlet weak var settingsButton: UIButton!
    
    
    
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
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //        // Get location
        //        locationManager.delegate = self
        //        locationManager.requestLocation()
        //        //
        toolbar.backgroundColor = UIColor.clear
        
        testButton.layer.cornerRadius = 5
        testButton.setTitle("Map", for: .normal)
        testButton.setTitleColor(UIColor.white, for: .normal)
        testButton.backgroundColor = UIColor.gray.withAlphaComponent(0.85)
        
        mapVC = MaplyViewController(mapType: .typeFlat)
        displayView.addSubview(mapVC!.view)
        mapVC!.view.frame = displayView.bounds
        addChild(mapVC!)
        mapVC!.view.isHidden = true
        mapVC!.rotateGesture = false
        
        globeVC = WhirlyGlobeViewController()
        displayView.addSubview(globeVC!.view)
        globeVC!.view.frame = displayView.bounds
        addChild(globeVC!)
        globeVC!.view.isHidden = false
        globeVC!.setZoomLimitsMin(0.000002, max: 1.5)
        
        // we want a black background for a globe, a white background for a map.
        globeVC!.clearColor = (globeVC != nil) ? UIColor.black : UIColor.white
        globeVC!.frameInterval = 3
        
        // set up the data source MAP
        //        if let tileSource = MaplyMBTileSource(mbTiles: "geography-class_medres"),
        //            let layer = MaplyQuadImageTilesLayer(tileSource: tileSource) {
        //            layer.handleEdges = (globeVC != nil)
        //            layer.coverPoles = (globeVC != nil)
        //            layer.requireElev = false
        //            layer.waitLoad = false
        //            layer.drawPriority = 0
        //            layer.singleLevelLoading = false
        //            mapVC!.add(layer)
        //        }
        
        
        //GLOBE
        // mousebird.github.io/WhirlyGlobe/tutorial/ios/remote_image_layer.html
        let useLocalTiles = false
        let globeLayer: MaplyQuadImageTilesLayer
        
        if useLocalTiles {
            guard let tileSource = MaplyMBTileSource(mbTiles: "geography-class_medres") else {
                print("Can't load local tile set")
            }
            globeLayer = MaplyQuadImageTilesLayer(tileSource: tileSource)!
        } else {
            let baseCacheDir = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)[0]
            let tilesCacheDir = "\(baseCacheDir)/stamentiles/"
            let maxZoom = Int32(18)
            
            guard let tileSource = MaplyRemoteTileSource(
                baseURL: "http://tile.stamen.com/terrain/",
                ext: "png",
                minZoom: 0,
                maxZoom: maxZoom) else {
                    print("Can't create a remote tile source")
                    return
            }
            tileSource.cacheDir = tilesCacheDir
            globeLayer = MaplyQuadImageTilesLayer(tileSource: tileSource)!
            globeVC!.add(globeLayer)
        }
        
        //MAP
        let mapLayer: MaplyQuadImageTilesLayer
        
        if useLocalTiles {
            guard let tileSource = MaplyMBTileSource(mbTiles: "geography-class_medres") else {
                print("Can't load local tile set")
            }
            mapLayer = MaplyQuadImageTilesLayer(tileSource: tileSource)!
        } else {
            let baseCacheDir = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)[0]
            let tilesCacheDir = "\(baseCacheDir)/stamentiles/"
            let maxZoom = Int32(18)
            
            guard let tileSource = MaplyRemoteTileSource(
                baseURL: "http://tile.stamen.com/terrain/",
                ext: "png",
                minZoom: 0,
                maxZoom: maxZoom) else {
                    print("Can't create a remote tile source")
                    return
            }
            tileSource.cacheDir = tilesCacheDir
            mapLayer = MaplyQuadImageTilesLayer(tileSource: tileSource)!
            mapVC!.add(mapLayer)
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
        
        //Testing Markers
        let mark = UIImage(named: "Mark")
        let markMarker = MaplyScreenMarker()
        markMarker.image = mark
        markMarker.loc = MaplyCoordinateMakeWithDegrees(-122.4192, 37.7793)
        markMarker.size = CGSize(width: 40, height: 40)
        //
        
        globeVC!.height = 0.5
        globeVC!.keepNorthUp = true
        globeVC!.animate(toPosition: MaplyCoordinateMakeWithDegrees(260.6704803, 30.5023056), time: 1.0)
        globeVC!.addScreenMarkers([markMarker], desc: nil)
        
        mapVC!.height = 1
        mapVC!.viewWrap = true
        mapVC!.animate(toPosition: MaplyCoordinateMakeWithDegrees(260.6704803, 30.5023056), time: 1.0)
        mapVC!.addScreenMarkers([markMarker], desc: nil)
        
        displayView.bringSubviewToFront(testButton)
        view.bringSubviewToFront(toolbar)
        
        globeVC!.startLocationTracking(with: self, useHeading: true, useCourse: true, simulate: true)
        mapVC!.startLocationTracking(with: self, useHeading: true, useCourse: true, simulate: true)
    }
    
    func getSimulationPoint() -> MaplyLocationTrackerSimulationPoint {
        return MaplyLocationTrackerSimulationPoint(lonDeg: longitude, latDeg: latitude, headingDeg: 180.0)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
    }
    
    func locationManager(_ manager: CLLocationManager, didChange status: CLAuthorizationStatus) {
        
    }
    
    //    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    //        if let location = locations.first {
    //            print("Found user's location: \(location)")
    //        }
    //    }
    //
    //    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    //        print("Failed to find the user's location: \(error.localizedDescription)")
    //    }
    
}

// globeVC!.stopLocationTracking()
