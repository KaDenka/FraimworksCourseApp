//
//  MapViewController.swift
//  FrameworksCourseApp
//
//  Created by Denis Kazarin on 10.03.2022.
//

import UIKit
import GoogleMaps
import CoreLocation
import RealmSwift
import Realm
import RxSwift
import RxCocoa
import AVFoundation

//MARK: -- Markers style enum

enum MarkerSelected {
    case autoMarker
    case manualMarker
}
//MARK: -- Controller

class MapViewController: UIViewController {
    
    //MARK: - Outlets
    
    @IBOutlet weak var mapView: GMSMapView!
    
    //MARK: - Properties
    
    var marker: GMSMarker?
    var manualMarker: GMSMarker?
    var geoCoder: CLGeocoder?
    var locationsArray = [CLLocationCoordinate2D]()
    var route: GMSPolyline?
    var routePath: GMSMutablePath?
    var startFlag = false
    var realmRoutePoints: Results<LastRoutePoint>!
    var disposeBag = DisposeBag()
    var onTakePicture: ((UIImage) -> Void)?
    //  var coordinates = CLLocationCoordinate2D(latitude: 55.7282982, longitude: 37.5779991)
    //var locationManager = CLLocationManager()
    
    let realm = try! Realm()
    let locationManager = LocationManager()
    //let router: LaunchRouter?
    
    
    //MARK: - Overrided funcs
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureMap()
        // configureLocationManager()
        addLocationManagerObservers()
        print("REALM REALM REALM: \(String(describing: Realm.Configuration.defaultConfiguration.fileURL?.path))")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        mapView.delegate = self
        //        configureLocationManager()
        addObservers()
    }
    
    //MARK: - Funcs
    
    func addMarker(_ markerType: MarkerSelected, _ coordinate: CLLocationCoordinate2D) {
        
        switch markerType {
        case .autoMarker:
            marker = GMSMarker(position: coordinate)
            marker?.icon = GMSMarker.markerImage(with: .systemPink)
            marker?.title = "Auto Position"
            marker?.snippet = "Actual selected auto marker"
            marker?.map = mapView
            locationsArray.append(coordinate)
            //makeMapPath(locationsArray)
            
        case .manualMarker:
            manualMarker = GMSMarker(position: coordinate)
            manualMarker?.icon = GMSMarker.markerImage(with: .systemGreen)
            manualMarker?.title = "Manual Position"
            manualMarker?.snippet = "Actual selected manual marker"
            manualMarker?.map = mapView
        }
    }
    
    func removeMarker() {
        marker?.map = nil
        marker = nil
    }
    
    func configureMap() {
        self.locationManager.location
            .asObservable()
            .bind { [weak self] loc in
                guard let loc = loc else { return }
                let cameraPosition = GMSCameraPosition.camera(withTarget: loc.coordinate, zoom: 17)
                self?.mapView.camera = cameraPosition
                self?.mapView.isMyLocationEnabled = true
                self?.mapView.settings.myLocationButton = true
            }
            .disposed(by: disposeBag)
//
//
//        let cameraPosition = GMSCameraPosition.camera(withTarget: coordinate, zoom: 17)
//        mapView.camera = cameraPosition
//        mapView.isMyLocationEnabled = true
//        mapView.settings.myLocationButton = true
        
    }
    
    //    func configureLocationManager() {
    //
    //        //locationManager = CLLocationManager()
    //        locationManager.delegate = self
    //        locationManager.requestAlwaysAuthorization()
    //        locationManager.allowsBackgroundLocationUpdates = true
    //        locationManager.startMonitoringSignificantLocationChanges()
    //        locationManager.pausesLocationUpdatesAutomatically = false
    //    }
    
    func makeMapPath(_ points: [CLLocationCoordinate2D]) {
        let routePath = GMSMutablePath()
        points.forEach { coordinate in
            routePath.add(coordinate)
        }
        let route = GMSPolyline(path: routePath)
        configureRouteLine(route)
        route.map = mapView
    }
    
    func configureRouteLine(_ route: GMSPolyline) {
        route.strokeWidth = 5.0
        route.strokeColor = .systemCyan
        route.geodesic = true
    }
    
    func showLastRoute() {
        realmRoutePoints = realm.objects(LastRoutePoint.self)
        guard realmRoutePoints != nil else {
            let alert = UIAlertController(title: "Warning!", message: "There is not any route in base", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            return  self.present(alert, animated: true, completion: nil)
        }
        routePath = GMSMutablePath()
        route = GMSPolyline()
        for point in realmRoutePoints {
            routePath!.add(CLLocationCoordinate2D(latitude: point.latitude, longitude: point.longitude))
        }
        self.route!.path = routePath
        self.route!.strokeColor = .systemRed
        self.route!.strokeWidth = 5.0
        self.route!.geodesic = true
        route!.map = mapView
        guard let firstPoint = (route?.path?.coordinate(at: 0)), let lastPoint = route?.path?.coordinate(at: ((routePath?.count())!) - 1) else { return }
        addMarker(.autoMarker, firstPoint)
        addMarker(.autoMarker, lastPoint)
        let bounds = GMSCoordinateBounds(coordinate: firstPoint, coordinate: lastPoint)
        let camera = mapView.camera(for: bounds, insets: UIEdgeInsets(top: 100, left: 100, bottom: 100, right: 100))!
        mapView.camera = camera
    }
    
    
    
    // MARK: -- Observers making funcs
    
    private func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(blurViewAdd), name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(normalViewAdd), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    private func addLocationManagerObservers() {
        self.locationManager.location
            .asObservable()
            .bind { [weak self] observedLocation in
                guard let observedLocation = observedLocation else { return }
                self?.routePath?.add(observedLocation.coordinate)
                self?.route?.path = self?.routePath
                
                let position = GMSCameraPosition(target: observedLocation.coordinate, zoom: 17)
                self?.mapView.animate(to: position)
            }
            .disposed(by: disposeBag)
    }
    
    //MARK: - @objc funcs
    
    @objc private func blurViewAdd() {
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.view.frame
        blurEffectView.tag = 2
        
        self.view.addSubview(blurEffectView)
    }
    
    @objc private func normalViewAdd() {
        self.view.viewWithTag(2)?.removeFromSuperview()
    }
    
    //MARK: - Actions
    
    @IBAction func createMarkerButton(_ sender: Any) {
        self.locationManager.location
            .asObservable()
            .bind { [weak self] loc in
                guard let loc = loc else { return }
                let coord = loc.coordinate
                self?.addMarker(.autoMarker, coord)
            }
            .disposed(by: disposeBag)
        
//        guard let coordinate = self.locationManager.location.coordinate as CLLocationCoordinate2D else { return }
//
        //    marker == nil ? addMarker(coordinates) : removeMarker()
      //  addMarker(.autoMarker, coordinate)
        //locationManager.stopUpdatingLocation()
        
    }
    
    
    @IBAction func updateLocationButton(_ sender: Any) {
        //locationManager.requestLocation()
        self.locationManager.location
            .asObservable()
            .bind { [weak self] loc in
                guard let loc = loc else { return }
                self?.mapView.camera = GMSCameraPosition(target: loc.coordinate, zoom: 17)
                
            }
            .disposed(by: disposeBag)
     
    }
    
    
    @IBAction func didTapStartRouteButton(_ sender: UIButton) {
        locationManager.manager.requestLocation()
        route?.map = nil
        removeMarker()
        route = GMSPolyline()
        configureRouteLine(route!)
        routePath = GMSMutablePath()
        route?.map = mapView
        locationManager.manager.startUpdatingLocation()
        startFlag = true
    }
    
    @IBAction func didTapStopRouteButton(_ sender: UIButton) {
        self.locationManager.manager.stopUpdatingLocation()
        route?.map = nil
        startFlag = false
        guard let routePoints = routePath else { return }
        try! realm.write{
            guard realmRoutePoints != nil else { return }
            realm.delete(realmRoutePoints)
        }
        
        for element in 0 ... (routePoints.count() - 1) {
            let routePoint = LastRoutePoint()
            routePoint.latitude = routePoints.coordinate(at: element).latitude
            routePoint.longitude = routePoints.coordinate(at: element).longitude
            
            try! realm.write {
                realm.add(routePoint)
            }
        }
        
        routePath?.removeAllCoordinates()
    }
    
    @IBAction func didTapLoadLastRouteButton(_ sender: UIButton) {
        if startFlag == true {
            let alert = UIAlertController(title: "Warning!", message: "The route is making now. If you'll press OK all data of this route will be lost", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                self.locationManager.manager.stopUpdatingLocation()
                // self.locationManager.stopUpdatingLocation()
                self.route?.map = nil
                self.startFlag = false
                self.showLastRoute()
            }))
            self.present(alert, animated: true, completion: nil)
        } else {
            showLastRoute()
        }
    }
    
    @IBAction func makePhotoButtonDidTapped(_ sender: UIButton) {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else { return }
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .camera
        imagePickerController.allowsEditing = true
        imagePickerController.delegate = self
        
        present(imagePickerController, animated: true)
    }
}

//MARK: -- Extensions

extension MapViewController: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        addMarker(.manualMarker, coordinate)
    }
    
}

extension MapViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    
    private func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        picker.dismiss(animated: true) { [weak self] in
        
            guard let image = self?.extractImage(from: info) else { return }
            self?.onTakePicture?(image)
        }
    }
    
    private func extractImage(from info: [String: Any]) -> UIImage? {
        if let image = info[UIImagePickerController.InfoKey.editedImage.rawValue] as? UIImage {
            return image
        } else if let image = info[UIImagePickerController.InfoKey.originalImage.rawValue] as? UIImage {
            return image
        } else {
            return nil
        }
    }
}

//extension MapViewController: CLLocationManagerDelegate {
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        //print(locations)
//
//        guard let location = locations.last else { return }
//
//        routePath?.add(location.coordinate)
//        route?.path = routePath
//
//        let position = GMSCameraPosition(target: location.coordinate, zoom: 17)
//        mapView.animate(to: position)
//
//
//
//
//        //        if geoCoder == nil {
//        //            geoCoder = CLGeocoder()
//        //        }
//        //        geoCoder?.reverseGeocodeLocation(location) { places, error in
//        //            print(places?.first)
//        //        }
//
//        //configureMap(location.coordinate)
//        //        mapView.camera = GMSCameraPosition(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude, zoom: 17)
//
//    }
//
//    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
//        print(error)
//    }
//}

