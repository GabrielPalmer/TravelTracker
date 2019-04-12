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
//// Add comment to pin with alert controller ////

class MapViewController: UIViewController, MaplyLocationTrackerDelegate, WhirlyGlobeViewControllerDelegate, MaplyViewControllerDelegate {
    
    private var globeVC: WhirlyGlobeViewController? //myViewC
    private var mapVC: MaplyViewController?
    
    var markerArray: [Marker] = []
    var globeIsVisible: Bool = true
    var lastTappedCoordinate: MaplyCoordinate = MaplyCoordinate(x: 0, y: 0)
    var currentMarker: Marker?
    var markerComponents: [MaplyComponentObject] = []
    var latitude: Float = 40.419774
    var longitude: Float = -111.885743
    
    @IBOutlet weak var displayView: UIView!
    
    @IBOutlet weak var toolbar: UIView!
    
    @IBOutlet weak var addPinButton: UIButton!
    
    @IBOutlet weak var addCommentButton: UIButton!
    
    @IBOutlet weak var addPictureButton: UIButton!
    
    @IBOutlet weak var friendsButton: UIButton!
    
    @IBOutlet weak var settingsButton: UIButton!
    
    @IBOutlet weak var pinEditorToolbar: UIView!
    
    @IBOutlet weak var defaultToolbar: UIView!
    
    @IBOutlet weak var addAndRemovePinButton: UIButton!
    
    @IBOutlet weak var mapTypeButton: UIButton!
    
    @IBAction func mapTypeButtonTapped(_ sender: Any) {
        if globeIsVisible {
            globeIsVisible = !globeIsVisible
            mapTypeButton.setTitle("Globe", for: .normal)
            mapTypeButton.setTitleColor(UIColor.white, for: .normal)
            mapTypeButton.backgroundColor = UIColor.gray.withAlphaComponent(0.8)
            globeVC!.view.isHidden = true
            mapVC!.view.isHidden = false
        } else if !globeIsVisible {
            globeIsVisible = !globeIsVisible
            mapTypeButton.setTitle("Map", for: .normal)
            mapTypeButton.setTitleColor(UIColor.white, for: .normal)
            mapTypeButton.backgroundColor = UIColor.gray.withAlphaComponent(0.8)
            mapVC!.view.isHidden = true
            globeVC!.view.isHidden = false
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        // Makes it so the ugly top of the iphone xr look pretty
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        defaultToolbar.isHidden = false
        pinEditorToolbar.isHidden = true
        
        toolbar.backgroundColor = UIColor.clear
        
        mapTypeButton.layer.cornerRadius = 5
        mapTypeButton.setTitle("Map", for: .normal)
        mapTypeButton.setTitleColor(UIColor.white, for: .normal)
        mapTypeButton.backgroundColor = UIColor.gray.withAlphaComponent(0.85)
        
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
        
        globeVC!.height = 0.5
        globeVC!.keepNorthUp = true
        globeVC!.animate(toPosition: MaplyCoordinateMakeWithDegrees(260.6704803, 30.5023056), time: 1.0)
        
        mapVC!.height = 1
        mapVC!.viewWrap = true
        mapVC!.animate(toPosition: MaplyCoordinateMakeWithDegrees(260.6704803, 30.5023056), time: 1.0)
        
        displayView.bringSubviewToFront(mapTypeButton)
        view.bringSubviewToFront(toolbar)
        
    }
    
    func globeViewController(_ viewC: WhirlyGlobeViewController, didSelect selectedObj: NSObject) {
        if let selectedObject = selectedObj as? MaplyScreenMarker {
            addGlobeAnnotationWithTitle(title: "selected", subtitle: "marker", loc: selectedObject.loc)
        }
        markerComponents.removeFirst()
        
        defaultToolbar.isHidden = true
        pinEditorToolbar.isHidden = false
        addAndRemovePinButton.setTitle("Remove Pin", for: .normal)
    }
    
    func maplyViewController(_ viewC: MaplyViewController, didSelect selectedObj: NSObject) {
        if let selectedObject = selectedObj as? MaplyScreenMarker {
            addGlobeAnnotationWithTitle(title: "selected", subtitle: "marker", loc: selectedObject.loc)
        }
        defaultToolbar.isHidden = true
        pinEditorToolbar.isHidden = false
        addAndRemovePinButton.setTitle("Remove Pin", for: .normal)
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
        defaultToolbar.isHidden = true
        pinEditorToolbar.isHidden = false
        addAndRemovePinButton.setTitle("Add Pin", for: .normal)
    }
    
    func maplyViewController(_ viewC: MaplyViewController, didTapAt coord: MaplyCoordinate) {
        let title = "Add Pin Here?"
        let subtitle = ""
        addMapAnnotationWithTitle(title: title, subtitle: subtitle, loc: coord)
        lastTappedCoordinate = coord
        defaultToolbar.isHidden = true
        pinEditorToolbar.isHidden = false
        addAndRemovePinButton.setTitle("Add Pin", for: .normal)
    }
    
    func globeViewControllerDidStartMoving(_ viewC: WhirlyGlobeViewController, userMotion: Bool) {
        if userMotion {
            globeVC!.clearAnnotations()
            defaultToolbar.isHidden = false
            pinEditorToolbar.isHidden = true
        }
    }
    
    func maplyViewControllerDidStartMoving(_ viewC: MaplyViewController, userMotion: Bool) {
        if userMotion {
            mapVC!.clearAnnotations()
            defaultToolbar.isHidden = false
            pinEditorToolbar.isHidden = true
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
    }
    
    func locationManager(_ manager: CLLocationManager, didChange status: CLAuthorizationStatus) {
        
    }
    
    @IBAction func addPinButtonTapped(_ sender: Any) {
        
    }
    
    @IBAction func addAndRemovePinButtonTapped(_ sender: Any) {
        if addAndRemovePinButton.titleLabel?.text == "Add Pin" {
            let redPin = UIImage(named: "Red-Pin")
            let redPinMarker = MaplyScreenMarker()
            redPinMarker.image = redPin
            redPinMarker.loc = lastTappedCoordinate
            redPinMarker.size = CGSize(width: 17.9, height: 36.4)
            
            if globeIsVisible {
                globeVC!.clearAnnotations()
                let marker = globeVC!.addScreenMarkers([redPinMarker], desc: nil)
                if let marker = marker {
                    markerComponents.append(marker)
                }
                markerArray.append(Marker(xCoord: lastTappedCoordinate.x, yCoord: lastTappedCoordinate.y))
            } else if !globeIsVisible {
                mapVC!.clearAnnotations()
                mapVC!.addScreenMarkers([redPinMarker], desc: nil)
                markerArray.append(Marker(xCoord: lastTappedCoordinate.x, yCoord: lastTappedCoordinate.y))
            }
            defaultToolbar.isHidden = false
            pinEditorToolbar.isHidden = true
        } else if addAndRemovePinButton.titleLabel?.text == "Remove Pin" {
            
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
