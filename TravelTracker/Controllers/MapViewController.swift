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
import Network
//// Add comment to pin with alert controller ////

class MapViewController: UIViewController, WhirlyGlobeViewControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, CLLocationManagerDelegate {
    
    let globeVC: WhirlyGlobeViewController = WhirlyGlobeViewController()
    let networkPath: NWPathMonitor = NWPathMonitor()
    let locationManager = CLLocationManager()
    var trackingFinished = false
    var lastTrackedLocation: MaplyCoordinate? = nil {
        didSet{
            if lastTrackedLocation != nil {
                setPinToCurrentLocation()
            } else {
                print("Something")
            }
            locationManager.stopUpdatingLocation()
        }
    }
    
    var mapMarkers: [MapMarker] = []
    
    var currentSelectedMarkerIndex: Int?
    var lastTappedCoordinate: MaplyCoordinate = MaplyCoordinate(x: 0, y: 0)
    
    @IBOutlet weak var displayView: UIView!
    
    @IBOutlet weak var toolbar: UIView!
    
    @IBOutlet weak var pinCurrentLocation: UIButton!
    
    @IBOutlet weak var addCommentButton: UIButton!
    
    @IBOutlet weak var addPictureButton: UIButton!
    
    @IBOutlet weak var friendsButton: UIButton!
    
    @IBOutlet weak var settingsButton: UIButton!
    
    @IBOutlet weak var markerEditorToolbar: UIView!
    
    @IBOutlet weak var defaultToolbar: UIView!
    
    @IBOutlet weak var removePinButton: UIButton!
    
    @IBOutlet weak var markerDetailView: UIView!
    
    @IBOutlet weak var nameDateLabel: UILabel!
    
    @IBOutlet weak var markerCommentLabel: UITextView!
    
    @IBOutlet weak var markerImageView: UIImageView!
    
    override var prefersStatusBarHidden: Bool {
        // Makes it so the ugly top of the iphone xr look pretty
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        settingsButton.imageView?.contentMode = .scaleAspectFit
        friendsButton.imageView?.contentMode = .scaleAspectFit
        pinCurrentLocation.imageView?.contentMode = .scaleAspectFit
        markerCommentLabel.showsVerticalScrollIndicator = true
        markerCommentLabel.indicatorStyle = .white
        markerCommentLabel.superview?.layer.cornerRadius = 25
        markerCommentLabel.textColor = UIColor.gray
        markerDetailView.isHidden = true
        markerDetailView.backgroundColor = UIColor.black.withAlphaComponent(1)
        markerCommentLabel.superview?.backgroundColor = UIColor.black.withAlphaComponent(1)
        defaultToolbar.isHidden = false
        markerEditorToolbar.isHidden = true
        //        addPinButton.setAttributedTitle(NSAttributedString(string: "Pin Current Location", attributes: [NSAttributedString.Key.font : UIFont(name: "Futura", size: 15) as Any]), for: .normal)
        markerDetailView.layer.cornerRadius = 25
        markerImageView.layer.masksToBounds = true
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
        
        let globeLayer: MaplyQuadImageTilesLayer
        
        
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
        globeVC.height = 0.5
        globeVC.keepNorthUp = true
        globeVC.animate(toPosition: MaplyCoordinateMakeWithDegrees(260.6704803, 30.5023056), time: 1.0)
        view.bringSubviewToFront(toolbar)
        displayView.bringSubviewToFront(markerDetailView)
        
        // Setup Own Pins \\
        
        for marker in FirebaseController.shared.currentUser!.markers {
            let mapMarker = MapMarker(info: marker)
            mapMarker.screenMarker.size = CGSize(width: 18, height: 36)
            mapMarker.screenMarker.offset = CGPoint(x: 0, y: 17)
            mapMarker.screenMarker.image = UIImage(named: "Red-Pin")
            mapMarker.screenMarker.loc = MaplyCoordinate(x: marker.xCoord, y: marker.yCoord)
            mapMarker.component = globeVC.addScreenMarkers([mapMarker.screenMarker], desc: nil)
            mapMarker.user = FirebaseController.shared.currentUser
            mapMarkers.append(mapMarker)
        }
        
        // Setup Friends Pins \\
        
        for friend in FirebaseController.shared.friends {
            for marker in friend.markers {
                let mapMarker = MapMarker(info: marker)
                mapMarker.screenMarker.size = CGSize(width: 18, height: 36)
                mapMarker.screenMarker.image = UIImage(named: "White-Pin")
                mapMarker.screenMarker.offset = CGPoint(x: 0, y: 17)
                mapMarker.screenMarker.color = friend.color
                mapMarker.screenMarker.loc = MaplyCoordinate(x: marker.xCoord, y: marker.yCoord)
                mapMarker.component = globeVC.addScreenMarkers([mapMarker.screenMarker], desc: nil)
                mapMarker.user = friend
                mapMarkers.append(mapMarker)
            }
        }
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
        
        // Check if this marker is already selected
        guard currentSelectedMarkerIndex != newSelectedMarkerIndex else { return }
        
        //check if a different marker is currently selected
        deselectCurrentMarker()
        
        let greenMarker = MaplyScreenMarker()
        greenMarker.size = CGSize(width: 18, height: 36)
        greenMarker.offset = CGPoint(x: 0, y: 17)
        greenMarker.image = UIImage(named: "Green-Pin")
        greenMarker.loc = mapMarker.screenMarker.loc
        let component = viewC.addScreenMarkers([greenMarker], desc: nil)
        
        globeVC.remove(selectedComponent)
        mapMarker.screenMarker = greenMarker
        mapMarker.component = component
        
        currentSelectedMarkerIndex = newSelectedMarkerIndex
        if mapMarker.user === FirebaseController.shared.currentUser {
            defaultToolbar.isHidden = true
            markerEditorToolbar.isHidden = false
            removePinButton.setAttributedTitle(NSAttributedString(string: "Remove Pin", attributes: [NSAttributedString.Key.font : UIFont(name: "Futura", size: 15) as Any]), for: .normal)
            nameDateLabel.text = ("\(mapMarker.user!.name) - \(mapMarker.info.date.formatAsString())")
            
        } else {
            defaultToolbar.isHidden = false
            markerEditorToolbar.isHidden = true
            nameDateLabel.text = ("\(mapMarker.user!.name) - \(mapMarker.info.date.formatAsString())")
        }
        updateMarkerEditor(mapMarker)
    }
    
    @objc func annotationButtonTapped() {
        let marker = MapMarker(info: MarkerInfo(xCoord: lastTappedCoordinate.x, yCoord: lastTappedCoordinate.y))
        marker.screenMarker.size = CGSize(width: 18, height: 36)
        marker.screenMarker.offset = CGPoint(x: 0, y: 17)
        marker.screenMarker.image = UIImage(named: "Green-Pin")
        marker.screenMarker.loc = lastTappedCoordinate
        marker.component = globeVC.addScreenMarkers([marker.screenMarker], desc: nil)
        marker.user = FirebaseController.shared.currentUser
        mapMarkers.append(marker)
        currentSelectedMarkerIndex = (mapMarkers.count - 1)
        updateMarkerEditor(marker)
        removePinButton.setAttributedTitle(NSAttributedString(string: "Remove Pin", attributes: [NSAttributedString.Key.font : UIFont(name: "Futura", size: 15) as Any]), for: .normal)
        globeVC.clearAnnotations()
        defaultToolbar.isHidden = true
        markerEditorToolbar.isHidden = false
        FirebaseController.shared.updateMapMarkers(marker, type: .add)
        FirebaseController.shared.currentUser?.markers.append(marker.info)
        nameDateLabel.text = ("\(marker.user!.name) - \(marker.info.date.formatAsString())")
    }
    
    func globeViewController(_ viewC: WhirlyGlobeViewController, didTapAt coord: MaplyCoordinate) {
        if globeVC.annotations()?.count == 0 {
            globeVC.clearAnnotations()
            markerDetailView.isHidden = true
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
            lastTappedCoordinate = coord
            deselectCurrentMarker()
        } else {
            globeVC.clearAnnotations()
        }
        markerEditorToolbar.isHidden = true
        defaultToolbar.isHidden = false
    }
    
    func globeViewControllerDidTapOutside(_ viewC: WhirlyGlobeViewController) {
        globeVC.clearAnnotations()
        markerDetailView.isHidden = true
        deselectCurrentMarker()
        markerEditorToolbar.isHidden = true
        defaultToolbar.isHidden = false
    }
    
    func globeViewControllerDidStartMoving(_ viewC: WhirlyGlobeViewController, userMotion: Bool) {
        if userMotion {
            globeVC.clearAnnotations()
            markerDetailView.isHidden = true
            defaultToolbar.isHidden = false
            markerEditorToolbar.isHidden = true
            deselectCurrentMarker()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if !trackingFinished {
            guard let lastLocation = locations.last else { return }
            lastTrackedLocation = MaplyCoordinate(x: Float(lastLocation.coordinate.longitude)*(Float.pi/180), y: Float(lastLocation.coordinate.latitude)*(Float.pi/180))
            trackingFinished = true
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        lastTrackedLocation = nil
        return
    }
    
    func startReceivingLocationChanges() {
        let authorizationStatus = CLLocationManager.authorizationStatus()
        if authorizationStatus != .authorizedWhenInUse && authorizationStatus != .authorizedAlways {
            // User has not authorized access to location information.
            return
        }
        // Do not start services that aren't available.
        if !CLLocationManager.locationServicesEnabled() {
            // Location services is not available.
            return
        }
        // Configure and start the service.
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.distanceFilter = 100.0 // In meters
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
    }
    
    func setPinToCurrentLocation() {
        let marker = MapMarker(info: MarkerInfo(xCoord: lastTrackedLocation!.x, yCoord: lastTrackedLocation!.y))
        marker.screenMarker.size = CGSize(width: 18, height: 36)
        marker.screenMarker.offset = CGPoint(x: 0, y: 17)
        marker.screenMarker.image = UIImage(named: "Green-Pin")
        marker.screenMarker.loc = MaplyCoordinate(x: lastTrackedLocation!.x, y: lastTrackedLocation!.y)
        marker.component = globeVC.addScreenMarkers([marker.screenMarker], desc: nil)
        marker.user = FirebaseController.shared.currentUser
        mapMarkers.append(marker)
        currentSelectedMarkerIndex = (mapMarkers.count - 1)
        updateMarkerEditor(marker)
        removePinButton.setAttributedTitle(NSAttributedString(string: "Remove Pin", attributes: [NSAttributedString.Key.font : UIFont(name: "Futura", size: 15) as Any]), for: .normal)
        globeVC.clearAnnotations()
        defaultToolbar.isHidden = true
        markerEditorToolbar.isHidden = false
        FirebaseController.shared.updateMapMarkers(marker, type: .add)
        FirebaseController.shared.currentUser?.markers.append(marker.info)
        nameDateLabel.text = ("\(marker.user!.name) - \(marker.info.date.formatAsString())")
        globeVC.animate(toPosition: MaplyCoordinate(x: marker.info.xCoord, y: marker.info.yCoord), time: 0.5)
        pinCurrentLocation.isEnabled = true
        pinCurrentLocation.imageView?.alpha = 1.0
    }
    
    @IBAction func pinCurrentLocationButtonTapped(_ sender: Any) {
        startReceivingLocationChanges()
        pinCurrentLocation.isEnabled = false
        pinCurrentLocation.imageView?.alpha = 0.5
        trackingFinished = false
    }
    
    @IBAction func settingsButtonTapped(_ sender: Any) {
        deselectCurrentMarker()
        performSegue(withIdentifier: "settingsSegue", sender: nil)
    }
    
    @IBAction func friendsButtonTapped(_ sender: Any) {
        deselectCurrentMarker()
        performSegue(withIdentifier: "friendsSegue", sender: nil)
    }
    
    @IBAction func unwindToGlobeVC(sender: UIStoryboardSegue) {
        if let source = sender.source as? UITabBarController,
            let viewControllers = source.viewControllers,
            let friendVC = viewControllers[0] as? FriendsViewController,
            let requestVC = viewControllers[2] as? UsersRequestsViewController {
            var deletedMapMarkers: [Int] = []
            var deletedComponents: [MaplyComponentObject] = []
            let changedUsers: [User] = friendVC.changedUsers
            let addedUsers: [User] = requestVC.addedUsers
            
            for user in changedUsers {
                if !user.pinsVisible {
                    for index in 0...(mapMarkers.count - 1) {
                        let mapMarker = mapMarkers[index]
                        
                        if mapMarker.user === user {
                            guard let component = mapMarker.component else { return }
                            deletedComponents.append(component)
                            deletedMapMarkers.append(index)
                        }
                    }
                } else {
                    for marker in user.markers {
                        let mapMarker = MapMarker(info: marker)
                        mapMarker.screenMarker.size = CGSize(width: 18, height: 36)
                        mapMarker.screenMarker.offset = CGPoint(x: 0, y: 17)
                        
                        if user === FirebaseController.shared.currentUser {
                            mapMarker.screenMarker.image = UIImage(named: "Red-Pin")
                        } else {
                            mapMarker.screenMarker.image = UIImage(named: "White-Pin")
                            mapMarker.screenMarker.color = user.color
                        }
                        
                        mapMarker.screenMarker.loc = MaplyCoordinate(x: marker.xCoord, y: marker.yCoord)
                        mapMarker.component = globeVC.addScreenMarkers([mapMarker.screenMarker], desc: nil)
                        mapMarker.user = user
                        mapMarkers.append(mapMarker)
                    }
                }
            }
            for user in addedUsers {
                if !user.pinsVisible {
                    for index in 0...(mapMarkers.count - 1) {
                        let mapMarker = mapMarkers[index]
                        
                        if mapMarker.user === user {
                            guard let component = mapMarker.component else { return }
                            deletedComponents.append(component)
                            deletedMapMarkers.append(index)
                        }
                    }
                } else {
                    for marker in user.markers {
                        let mapMarker = MapMarker(info: marker)
                        mapMarker.screenMarker.size = CGSize(width: 18, height: 36)
                        mapMarker.screenMarker.offset = CGPoint(x: 0, y: 17)
                        mapMarker.screenMarker.image = UIImage(named: "White-Pin")
                        mapMarker.screenMarker.color = user.color
                        mapMarker.screenMarker.loc = MaplyCoordinate(x: marker.xCoord, y: marker.yCoord)
                        mapMarker.component = globeVC.addScreenMarkers([mapMarker.screenMarker], desc: nil)
                        mapMarker.user = user
                        mapMarkers.append(mapMarker)
                    }
                }
            }
            if !deletedMapMarkers.isEmpty && !deletedComponents.isEmpty {
                mapMarkers.remove(at: deletedMapMarkers)
                globeVC.remove(deletedComponents)
            }
            friendVC.changedUsers.removeAll()
        }
    }
    
    @IBAction func removePinButtonTapped(_ sender: Any) {
        if removePinButton.titleLabel?.text == "Remove Pin" {
            guard let currentSelectedMarkerIndex = currentSelectedMarkerIndex else {
                print("Remove Pin was selected without currentSelectedMarkerIndex having a value.")
                return
            }
            let marker = mapMarkers[currentSelectedMarkerIndex]
            guard let component = marker.component else {
                print("marker didn't have component")
                return
            }
            FirebaseController.shared.updateMapMarkers(mapMarkers[currentSelectedMarkerIndex], type: .delete)
            globeVC.remove(component)
            mapMarkers.remove(at: currentSelectedMarkerIndex)
            self.currentSelectedMarkerIndex = nil
            markerDetailView.isHidden = true
            markerEditorToolbar.isHidden = true
            defaultToolbar.isHidden = false
            var deletedMarkers: [Int] = []
            for index in 0...(FirebaseController.shared.currentUser!.markers.count - 1) {
                if FirebaseController.shared.currentUser!.markers[index].id == marker.info.id {
                    deletedMarkers.append(index)
                }
            }
            FirebaseController.shared.currentUser!.markers.remove(at: deletedMarkers)
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
        guard let currentMarkerIndex = self.currentSelectedMarkerIndex else { return }
        let mapMarker = mapMarkers[currentMarkerIndex]
        let alert = UIAlertController(title: mapMarker.info.comment == nil ? "Add a comment" : "Edit Comment", message: nil, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addTextField { (textField) in
            textField.text = mapMarker.info.comment
            textField.delegate = self
            textField.placeholder = "Add comment here."
        }
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            if let comment = alert.textFields?.first?.text, !comment.isEmpty {
                mapMarker.info.comment = comment
                self.updateMarkerEditor(mapMarker)
                FirebaseController.shared.updateMapMarkers(mapMarker, type: .update)
            } else {
                mapMarker.info.comment = nil
                self.updateMarkerEditor(mapMarker)
                FirebaseController.shared.updateMapMarkers(mapMarker, type: .update)
            }
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
        FirebaseController.shared.updateMapMarkers(mapMarkers[currentMarker], type: .update)
        //Dismiss the picker.
        dismiss(animated: true, completion: nil)
    }
    
    func updateMarkerEditor(_ marker: MapMarker) {
        if marker.info.image == nil && marker.info.comment == nil {
            addCommentButton.setAttributedTitle(NSAttributedString(string: "Add Comment", attributes: [NSAttributedString.Key.font : UIFont(name: "Futura", size: 15) as Any]), for: .normal)
            addPictureButton.setAttributedTitle(NSAttributedString(string: "Add Picture", attributes: [NSAttributedString.Key.font : UIFont(name: "Futura", size: 15) as Any]), for: .normal)
            markerDetailView.isHidden = true
        } else if marker.info.image == nil && marker.info.comment != nil {
            addCommentButton.setAttributedTitle(NSAttributedString(string: "Edit Comment", attributes: [NSAttributedString.Key.font : UIFont(name: "Futura", size: 15) as Any]), for: .normal)
            addPictureButton.setAttributedTitle(NSAttributedString(string: "Add Picture", attributes: [NSAttributedString.Key.font : UIFont(name: "Futura", size: 15) as Any]), for: .normal)
            markerDetailView.isHidden = false
            markerCommentLabel.superview?.isHidden = false
            markerCommentLabel.text = marker.info.comment
            markerImageView.isHidden = true
        } else if marker.info.comment == nil && marker.info.image != nil {
            addCommentButton.setAttributedTitle(NSAttributedString(string: "Add Comment", attributes: [NSAttributedString.Key.font : UIFont(name: "Futura", size: 15) as Any]), for: .normal)
            addPictureButton.setAttributedTitle(NSAttributedString(string: "Edit Picture", attributes: [NSAttributedString.Key.font : UIFont(name: "Futura", size: 15) as Any]), for: .normal)
            markerDetailView.isHidden = false
            markerImageView.isHidden = false
            markerCommentLabel.superview?.isHidden = true
            markerImageView.image = marker.info.image
        } else {
            addCommentButton.setAttributedTitle(NSAttributedString(string: "Edit Comment", attributes: [NSAttributedString.Key.font : UIFont(name: "Futura", size: 15) as Any]), for: .normal)
            addPictureButton.setAttributedTitle(NSAttributedString(string: "Edit Picture", attributes: [NSAttributedString.Key.font : UIFont(name: "Futura", size: 15) as Any]), for: .normal)
            markerDetailView.isHidden = false
            markerImageView.isHidden = false
            markerCommentLabel.superview?.isHidden = false
            markerImageView.image = marker.info.image
            markerCommentLabel.text = marker.info.comment
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let text = textField.text, text.count > 1000 {
            return false
        } else {
            return true
        }
    }
    
    func deselectCurrentMarker() {
        if let currentSelectedMarkerIndex = currentSelectedMarkerIndex {
            let mapMarker = mapMarkers[currentSelectedMarkerIndex]
            guard let selectedComponent = mapMarker.component else {
                print("marker didn't have component")
                return
            }
            let screenMarker = MaplyScreenMarker()
            screenMarker.size = CGSize(width: 18, height: 36)
            
            if mapMarker.user === FirebaseController.shared.currentUser {
                screenMarker.image = UIImage(named: "Red-Pin")
                screenMarker.offset = CGPoint(x: 0, y: 17)
            } else {
                screenMarker.image = UIImage(named: "White-Pin")
                screenMarker.offset = CGPoint(x: 0, y: 17)
                screenMarker.color = mapMarker.user?.color
            }
            
            screenMarker.loc = mapMarker.screenMarker.loc
            let component = globeVC.addScreenMarkers([screenMarker], desc: nil)
            
            globeVC.remove(selectedComponent)
            mapMarker.component = component
            mapMarker.screenMarker = screenMarker
            self.currentSelectedMarkerIndex = nil
        }
    }
    
    //    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    //        if let destination = segue.destination as? UINavigationController,
    //            let tabBar = destination.viewControllers[0] as? UITabBarController,
    //            let viewControllers = tabBar.viewControllers,
    //            let friendsVC = viewControllers[0] as? FriendsViewController {
    //            friendsVC.seguedFromGlobeVC()
    //        }
    //    }
}

