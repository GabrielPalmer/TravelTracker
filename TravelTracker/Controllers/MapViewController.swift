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

class MapViewController: UIViewController, MaplyLocationTrackerDelegate, WhirlyGlobeViewControllerDelegate, MaplyViewControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let globeVC: WhirlyGlobeViewController = WhirlyGlobeViewController() //myViewC
    
    var mapMarkers: [MapMarker] = []
    var globeIsVisible: Bool = true
    
    var markerInfo: MarkerInfo = MarkerInfo(xCoord: 0, yCoord: 0)
    var currentSelectedMarkerIndex: Int?
    var lastTappedCoordinate: MaplyCoordinate = MaplyCoordinate(x: 0, y: 0)
    
    var latitude: Float = 40.419774
    var longitude: Float = -111.885743
    
    @IBOutlet weak var displayView: UIView!
    
    @IBOutlet weak var toolbar: UIView!
    
    @IBOutlet weak var addPinButton: UIButton!
    
    @IBOutlet weak var addCommentButton: UIButton!
    
    @IBOutlet weak var addPictureButton: UIButton!
    
    @IBOutlet weak var friendsButton: UIButton!
    
    @IBOutlet weak var settingsButton: UIButton!
    
    @IBOutlet weak var markerEditorToolbar: UIView!
    
    @IBOutlet weak var defaultToolbar: UIView!
    
    @IBOutlet weak var addAndRemovePinButton: UIButton!
    
    @IBOutlet weak var markerDetailView: UIView!
    
    @IBOutlet weak var markerCommentLabel: UILabel!
    
    @IBOutlet weak var markerImageView: UIImageView!
    
    override var prefersStatusBarHidden: Bool {
        // Makes it so the ugly top of the iphone xr look pretty
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        markerDetailView.isHidden = true
        defaultToolbar.isHidden = false
        markerEditorToolbar.isHidden = true
        
        toolbar.backgroundColor = UIColor.clear
        
        displayView.addSubview(globeVC.view)
        globeVC.view.frame = displayView.bounds
        addChild(globeVC)
        
        globeVC.clearColor = UIColor.black
        globeVC.setZoomLimitsMin(0.000002, max: 1.5)
        globeVC.frameInterval = 2
        globeVC.keepNorthUp = true
        globeVC.view.isHidden = false
        globeVC.delegate = self
        globeVC.height = 0.5
        globeVC.autoMoveToTap = false
        
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
            globeVC.add(globeLayer)
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
        
        globeVC.height = 0.5
        globeVC.keepNorthUp = true
        globeVC.animate(toPosition: MaplyCoordinateMakeWithDegrees(260.6704803, 30.5023056), time: 1.0)
        view.bringSubviewToFront(toolbar)
        view.bringSubviewToFront(markerDetailView)
        
    }
    
    func globeViewController(_ viewC: WhirlyGlobeViewController, didSelect selectedObj: NSObject, atLoc coord: MaplyCoordinate, onScreen screenPt: CGPoint) {
        globeVC.clearAnnotations()
        guard let selectedScreenMarker = selectedObj as? MaplyScreenMarker else {
            print("selected object was not a MaplyScreenMarker")
            return
        }
        globeVC.animate(toPosition: coord, time: 0.5)
        
        guard let newSelectedMarkerIndex = mapmarkersIndex(for: selectedScreenMarker) else {
            print("Could not find mapMarkers index for the selected screen marker")
            return
        }
        
        let mapMarker = mapMarkers[newSelectedMarkerIndex]
        guard let selectedComponent = mapMarker.component else {
            print("MapMarker did not have a component")
            return
        }
        
        updateMarkerEditor(mapMarker)
        
        // Check if this marker is already selected
        guard currentSelectedMarkerIndex != newSelectedMarkerIndex else { return }
        
        //check if a different marker is currently selected
        if let currentSelectedMarkerIndex = currentSelectedMarkerIndex {
            let currentSelectedMapMarker = mapMarkers[currentSelectedMarkerIndex]
            
            let redMarker = MaplyScreenMarker()
            redMarker.size = CGSize(width: 18, height: 36)
            redMarker.image = UIImage(named: "Red-Pin")
            redMarker.loc = currentSelectedMapMarker.screenMarker.loc
            let component = globeVC.addScreenMarkers([redMarker], desc: nil)
            
            globeVC.remove(currentSelectedMapMarker.component!)
            currentSelectedMapMarker.screenMarker = redMarker
            currentSelectedMapMarker.component = component
        }
        
        let greenMarker = MaplyScreenMarker()
        greenMarker.size = CGSize(width: 18, height: 36)
        greenMarker.image = UIImage(named: "Green-Pin")
        greenMarker.loc = mapMarker.screenMarker.loc
        let component = viewC.addScreenMarkers([greenMarker], desc: nil)
        
        globeVC.remove(selectedComponent)
        mapMarker.screenMarker = greenMarker
        mapMarker.component = component
        
        currentSelectedMarkerIndex = newSelectedMarkerIndex
        
        defaultToolbar.isHidden = true
        markerEditorToolbar.isHidden = false
        addAndRemovePinButton.setTitle("Remove Pin", for: .normal)
    }
    
    @objc func annotationButtonTapped() {
        let marker = MapMarker(info: markerInfo)
        marker.screenMarker.size = CGSize(width: 18, height: 36)
        marker.screenMarker.image = UIImage(named: "Green-Pin")
        marker.screenMarker.loc = lastTappedCoordinate
        marker.component = globeVC.addScreenMarkers([marker.screenMarker], desc: nil)
        mapMarkers.append(marker)
        currentSelectedMarkerIndex = (mapMarkers.count - 1)
        updateMarkerEditor(marker)
        
        globeVC.clearAnnotations()
        addAndRemovePinButton.setTitle("Remove Pin", for: .normal)
        defaultToolbar.isHidden = true
        markerEditorToolbar.isHidden = false
    }
    
    func globeViewController(_ viewC: WhirlyGlobeViewController, didTapAt coord: MaplyCoordinate) {
        globeVC.clearAnnotations()
        //button annotation
        let annotation = MaplyAnnotation()
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 90, height: 10))
        button.setTitle("Add Pin Here?", for: .normal)
        button.titleLabel!.font = UIFont(name: "Futura", size: 13.657)
        button.setTitleColor(.blue, for: .normal)
        button.addTarget(self, action: #selector(annotationButtonTapped), for: .touchUpInside)
        annotation.contentView = button
        annotation.contentView.isUserInteractionEnabled = true
        ////////
        globeVC.addAnnotation(annotation, forPoint: coord, offset: .zero)
        globeVC.animate(toPosition: coord, time: 0.5)
        markerEditorToolbar.isHidden = false
        defaultToolbar.isHidden = true
        lastTappedCoordinate = coord
        addAndRemovePinButton.setTitle("Add Pin", for: .normal)
        if let currentSelectedMarkerIndex = currentSelectedMarkerIndex {
            let marker = mapMarkers[currentSelectedMarkerIndex]
            guard let selectedComponent = marker.component else {
                print("marker didn't have component")
                return
            }
            let redMarker = MaplyScreenMarker()
            redMarker.size = CGSize(width: 18, height: 36)
            redMarker.image = UIImage(named: "Red-Pin")
            redMarker.loc = marker.screenMarker.loc
            let component = globeVC.addScreenMarkers([redMarker], desc: nil)
            
            globeVC.remove(selectedComponent)
            marker.component = component
            marker.screenMarker = redMarker
            self.currentSelectedMarkerIndex = nil
        }
    }
    
    func globeViewControllerDidTapOutside(_ viewC: WhirlyGlobeViewController) {
        globeVC.clearAnnotations()
        if let currentSelectedMarkerIndex = currentSelectedMarkerIndex {
            let marker = mapMarkers[currentSelectedMarkerIndex]
            guard let selectedComponent = marker.component else {
                print("marker didn't have component")
                return
            }
            let redMarker = MaplyScreenMarker()
            redMarker.size = CGSize(width: 18, height: 36)
            redMarker.image = UIImage(named: "Red-Pin")
            redMarker.loc = marker.screenMarker.loc
            let component = globeVC.addScreenMarkers([redMarker], desc: nil)
            
            globeVC.remove(selectedComponent)
            marker.component = component
            marker.screenMarker = redMarker
            self.currentSelectedMarkerIndex = nil
            markerEditorToolbar.isHidden = false
            defaultToolbar.isHidden = true
        }
    }
    
    func globeViewControllerDidStartMoving(_ viewC: WhirlyGlobeViewController, userMotion: Bool) {
        if userMotion {
            globeVC.clearAnnotations()
            defaultToolbar.isHidden = false
            markerEditorToolbar.isHidden = true
            if let currentSelectedMarkerIndex = currentSelectedMarkerIndex {
                let marker = mapMarkers[currentSelectedMarkerIndex]
                guard let selectedComponent = marker.component else {
                    print("marker didn't have component")
                    return
                }
                let redMarker = MaplyScreenMarker()
                redMarker.size = CGSize(width: 18, height: 36)
                redMarker.image = UIImage(named: "Red-Pin")
                redMarker.loc = marker.screenMarker.loc
                let component = globeVC.addScreenMarkers([redMarker], desc: nil)
                globeVC.remove(selectedComponent)
                marker.component = component
                marker.screenMarker = redMarker
                self.currentSelectedMarkerIndex = nil
            }
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
            let marker = MapMarker(info: markerInfo)
            marker.screenMarker.size = CGSize(width: 18, height: 36)
            marker.screenMarker.image = UIImage(named: "Green-Pin")
            marker.screenMarker.loc = lastTappedCoordinate
            marker.component = globeVC.addScreenMarkers([marker.screenMarker], desc: nil)
            mapMarkers.append(marker)
            currentSelectedMarkerIndex = (mapMarkers.count - 1)
            updateMarkerEditor(marker)
            
            globeVC.clearAnnotations()
            addAndRemovePinButton.setTitle("Remove Pin", for: .normal)
            defaultToolbar.isHidden = true
            markerEditorToolbar.isHidden = false
        } else if addAndRemovePinButton.titleLabel?.text == "Remove Pin" {
            guard let currentSelectedMarkerIndex = currentSelectedMarkerIndex else {
                print("Remove Pin was selected without currentSelectedMarkerIndex having a value.")
                return
            }
            let marker = mapMarkers[currentSelectedMarkerIndex]
            guard let component = marker.component else {
                print("marker didn't have component")
                return
            }
            globeVC.remove(component)
            mapMarkers.remove(at: currentSelectedMarkerIndex)
            self.currentSelectedMarkerIndex = nil
            markerEditorToolbar.isHidden = true
            defaultToolbar.isHidden = false
        }
    }
    
    func mapmarkersIndex(for screenMarker: MaplyScreenMarker) -> Int? {
        
        for index in 0...mapMarkers.count - 1 {
            let marker = mapMarkers[index]
            
            if screenMarker === marker.screenMarker {
                return index
            }
        }
        
        return nil
    }
    
    @IBAction func addCommentButtonTapped(_ sender: Any) {
        let alert = UIAlertController(title: "Add a comment to this pin?", message: nil, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addTextField { (textField) in
            textField.placeholder = "Add comment here."
        }
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            guard let comment = alert.textFields?.first?.text else { return }
            guard let currentMarker = self.currentSelectedMarkerIndex else { return }
            self.mapMarkers[currentMarker].info.comment = comment
            self.updateMarkerEditor(self.mapMarkers[currentMarker])
        }))
        self.present(alert, animated: true)
    }
    
    @IBAction func addPictureButtonTapped(_ sender: Any) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        
        let alertController = UIAlertController(
            title: nil,
            message: nil,
            preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(
            title: "Cancel",
            style: .cancel,
            handler: nil)
        alertController.addAction(cancelAction)
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let photosAction = UIAlertAction(
                title: "Photos",
                style: .default) { _ in
                    imagePickerController.sourceType = .photoLibrary
                    self.present(imagePickerController, animated: true)
            }
            alertController.addAction(photosAction)
        }
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let cameraAction = UIAlertAction(
                title: "Camera",
                style: .default) { _ in
                    imagePickerController.sourceType = .camera
                    self.present(imagePickerController, animated: true)
            }
            alertController.addAction(cameraAction)
        }
        present(alertController, animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        //Dismiss the picker if the user canceled.
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ _picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        guard let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {fatalError()}
        guard let currentMarker = currentSelectedMarkerIndex else { return }
        mapMarkers[currentMarker].info.image = selectedImage
        updateMarkerEditor(mapMarkers[currentMarker])
        //Dismiss the picker.
        dismiss(animated: true, completion: nil)
    }
    
    func updateMarkerEditor(_ marker: MapMarker) {
        if marker.info.image == nil && marker.info.comment == nil {
            addCommentButton.setTitle("Add Comment", for: .normal)
            addPictureButton.setTitle("Add Picture", for: .normal)
            markerDetailView.isHidden = true
        } else if marker.info.image == nil && marker.info.comment != nil {
            addCommentButton.setTitle("Edit Comment", for: .normal)
            addPictureButton.setTitle("Add Picture", for: .normal)
            markerDetailView.isHidden = false
            markerCommentLabel.isHidden = false
            markerCommentLabel.text = marker.info.comment
            markerImageView.isHidden = true
        } else if marker.info.comment == nil && marker.info.image != nil {
            addCommentButton.setTitle("Add Comment", for: .normal)
            addPictureButton.setTitle("Edit Picture", for: .normal)
            markerDetailView.isHidden = false
            markerImageView.isHidden = false
            markerCommentLabel.isHidden = true
            markerImageView.image = marker.info.image
        } else {
            addCommentButton.setTitle("Edit Comment", for: .normal)
            addPictureButton.setTitle("Edit Picture", for: .normal)
            markerDetailView.isHidden = false
            markerImageView.isHidden = false
            markerCommentLabel.isHidden = false
            markerImageView.image = marker.info.image
            markerCommentLabel.text = marker.info.comment
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
