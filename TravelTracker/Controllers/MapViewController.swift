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

class MapViewController: UIViewController, MaplyLocationTrackerDelegate, WhirlyGlobeViewControllerDelegate, MaplyViewControllerDelegate {
    
    //    // get location
    //    let locationManager = CLLocationManager()
    //    //
    var globeIsVisible: Bool = true
    
    var lastTappedCoordinate: MaplyCoordinate = MaplyCoordinate(x: 0, y: 0)
    
    var latitude: Float = 40.419774
    var longitude: Float = -111.885743
    
    @IBOutlet weak var displayView: UIView!
    
    private var globeVC: WhirlyGlobeViewController? //myViewC
    private var mapVC: MaplyViewController?
    
    @IBOutlet weak var toolbar: UIView!
    
    @IBOutlet weak var addPinButton: UIButton!
    
    @IBOutlet weak var addCommentButton: UIButton!
    
    @IBOutlet weak var addPictureButton: UIButton!
    
    @IBOutlet weak var friendsButton: UIButton!
    
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
        mapVC!.delegate = self
        
        globeVC = WhirlyGlobeViewController()
        displayView.addSubview(globeVC!.view)
        globeVC!.view.frame = displayView.bounds
        addChild(globeVC!)
        globeVC!.view.isHidden = false
        globeVC!.setZoomLimitsMin(0.000002, max: 1.5)
        
        // we want a black background for a globe, a white background for a map.
        globeVC!.clearColor = (globeVC != nil) ? UIColor.black : UIColor.white
        globeVC!.frameInterval = 3
        globeVC!.delegate = self
        
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
        /* Mark Zuckerburg
         let mark = UIImage(named: "Mark")
         let markMarker = MaplyScreenMarker()
         markMarker.image = mark
         markMarker.loc = MaplyCoordinateMakeWithDegrees(-122.4192, 37.7793)
         markMarker.size = CGSize(width: 40, height: 40)
         */
        let redPin = UIImage(named: "Red-Pin")
        let redPinMarker = MaplyScreenMarker()
        redPinMarker.image = redPin
        redPinMarker.loc = MaplyCoordinateMakeWithDegrees(-111.885743, 40.419774)
        redPinMarker.size = CGSize(width: 17.9, height: 36.4)
        
        
        //
        
        globeVC!.height = 0.5
        globeVC!.keepNorthUp = true
        globeVC!.animate(toPosition: MaplyCoordinateMakeWithDegrees(260.6704803, 30.5023056), time: 1.0)
        globeVC!.addScreenMarkers([redPinMarker], desc: nil)
        //globeVC!.addScreenMarkers([markMarker], desc: nil)
        
        mapVC!.height = 1
        mapVC!.viewWrap = true
        mapVC!.animate(toPosition: MaplyCoordinateMakeWithDegrees(260.6704803, 30.5023056), time: 1.0)
        mapVC!.addScreenMarkers([redPinMarker], desc: nil)
        //mapVC!.addScreenMarkers([markMarker], desc: nil)
        
        displayView.bringSubviewToFront(testButton)
        view.bringSubviewToFront(toolbar)
        
    }
    
    //    func getSimulationPoint() -> MaplyLocationTrackerSimulationPoint {
    //        return MaplyLocationTrackerSimulationPoint(lonDeg: longitude, latDeg: latitude, headingDeg: 180.0)
    //    }
    
    func globeViewController(_ viewC: WhirlyGlobeViewController, didSelect selectedObj: NSObject) {
        if let selectedObject = selectedObj as? MaplyVectorObject {
            let loc = selectedObject.centroid()
            addGlobeAnnotationWithTitle(title: "selected", subtitle: selectedObject.userObject as! String, loc: loc)
        } else if let selectedObject = selectedObj as? MaplyScreenMarker {
            addGlobeAnnotationWithTitle(title: "selected", subtitle: "marker", loc: selectedObject.loc)
        }
    }
    
    func maplyViewController(_ viewC: MaplyViewController, didSelect selectedObj: NSObject) {
        if let selectedObject = selectedObj as? MaplyVectorObject {
            let loc = selectedObject.centroid()
            addGlobeAnnotationWithTitle(title: "selected", subtitle: selectedObject.userObject as! String, loc: loc)
        } else if let selectedObject = selectedObj as? MaplyScreenMarker {
            addGlobeAnnotationWithTitle(title: "selected", subtitle: "marker", loc: selectedObject.loc)
        }
    }
    
    private func addMapAnnotationWithTitle(title: String, subtitle: String, loc: MaplyCoordinate) {
        mapVC!.clearAnnotations()
        
        let a = MaplyAnnotation()
        a.title = title
        a.subTitle = subtitle
        
        mapVC!.addAnnotation(a, forPoint: loc, offset: CGPoint.zero)
    }
    
    private func addGlobeAnnotationWithTitle(title: String, subtitle: String, loc: MaplyCoordinate) {
        globeVC!.clearAnnotations()
        
        let a = MaplyAnnotation()
        a.title = title
        a.subTitle = subtitle
        
        globeVC!.addAnnotation(a, forPoint: loc, offset: CGPoint.zero)
    }
    
    func globeViewController(_ viewC: WhirlyGlobeViewController, didTapAt coord: MaplyCoordinate) {
        let title = "Add Pin Here?"
        let subtitle = ""
        addGlobeAnnotationWithTitle(title: title, subtitle: subtitle, loc: coord)
        lastTappedCoordinate = coord
    }
    
    func maplyViewController(_ viewC: MaplyViewController, didTapAt coord: MaplyCoordinate) {
        let title = "Add Pin Here?"
        let subtitle = ""
        addMapAnnotationWithTitle(title: title, subtitle: subtitle, loc: coord)
        lastTappedCoordinate = coord
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
    }
    
    func locationManager(_ manager: CLLocationManager, didChange status: CLAuthorizationStatus) {
        
    }
    
    @IBAction func addPinButtonTapped(_ sender: Any) {
        let redPin = UIImage(named: "Red-Pin")
        let redPinMarker = MaplyScreenMarker()
        redPinMarker.image = redPin
        redPinMarker.loc = lastTappedCoordinate
        redPinMarker.size = CGSize(width: 17.9, height: 36.4)
        
        if globeIsVisible {
            globeVC!.clearAnnotations()
            globeVC!.addScreenMarkers([redPinMarker], desc: nil)
        } else if !globeIsVisible {
            mapVC!.clearAnnotations()
            mapVC!.addScreenMarkers([redPinMarker], desc: nil)
        }
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
