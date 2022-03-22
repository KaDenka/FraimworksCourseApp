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

enum MarkerSelected {
    case autoMarker
    case manualMarker
}

class MapViewController: UIViewController {
    
    @IBOutlet weak var mapView: GMSMapView!
    
    var marker: GMSMarker?
    var manualMarker: GMSMarker?
    var locationManager = CLLocationManager()
    var geoCoder: CLGeocoder?
    var locationsArray = [CLLocationCoordinate2D]()
    var route: GMSPolyline?
    var routePath: GMSMutablePath?
    var startFlag = false
    var coordinates = CLLocationCoordinate2D(latitude: 55.7282982, longitude: 37.5779991)
    let realm = try! Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureMap(locationManager.location?.coordinate ?? coordinates)
        // configureLocationManager()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        mapView.delegate = self
        configureLocationManager()
    }
    
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
    
    func configureMap(_ coordinate: CLLocationCoordinate2D) {
        let cameraPosition = GMSCameraPosition.camera(withTarget: coordinate, zoom: 17)
        mapView.camera = cameraPosition
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
        
    }
    
    func configureLocationManager() {
        
        //locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.startMonitoringSignificantLocationChanges()
        locationManager.pausesLocationUpdatesAutomatically = false
    }
    
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
    
    @IBAction func createMarkerButton(_ sender: Any) {
        guard let coordinate = locationManager.location?.coordinate else { return }
        
        //    marker == nil ? addMarker(coordinates) : removeMarker()
        addMarker(.autoMarker, coordinate)
        //locationManager.stopUpdatingLocation()
        
    }
    
    
    @IBAction func updateLocationButton(_ sender: Any) {
        //locationManager.requestLocation()
        mapView.camera = GMSCameraPosition(target: locationManager.location!.coordinate, zoom: 17)
        
    }
    
    
    @IBAction func didTapStartRouteButton(_ sender: UIButton) {
        locationManager.requestLocation()
        route?.map = nil
        route = GMSPolyline()
        configureRouteLine(route!)
        routePath = GMSMutablePath()
        route?.map = mapView
        locationManager.startUpdatingLocation()
        startFlag = true
    }
    
    @IBAction func didTapStopRouteButton(_ sender: UIButton) {
        locationManager.stopUpdatingLocation()
        route?.map = nil
        startFlag = false
        
        
        guard let routePoints = routePath else { return }
        for element in 0 ... (routePoints.count() - 1) {
            print(routePoints.coordinate(at: element).longitude)
        }
        routePath?.removeAllCoordinates()
    }
    
    @IBAction func didTapLoadLastRouteButton(_ sender: UIButton) {
        if startFlag == true {
            let alert = UIAlertController(title: "Warning!", message: "The route is making now. If you'll press OK all data of this route will be lost", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                self.locationManager.stopUpdatingLocation()
                self.route?.map = nil
                self.startFlag = false
            }))
            self.present(alert, animated: true, completion: nil)
            
        } else {
            
        }
    }
    
    
    
    
    
}

extension MapViewController: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        addMarker(.manualMarker, coordinate)
    }
    
}

extension MapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //print(locations)
        
        guard let location = locations.last else { return }
        
        routePath?.add(location.coordinate)
        route?.path = routePath
        
        let position = GMSCameraPosition(target: location.coordinate, zoom: 17)
        mapView.animate(to: position)
        
        
        
        
        //        if geoCoder == nil {
        //            geoCoder = CLGeocoder()
        //        }
        //        geoCoder?.reverseGeocodeLocation(location) { places, error in
        //            print(places?.first)
        //        }
        
        //configureMap(location.coordinate)
        //        mapView.camera = GMSCameraPosition(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude, zoom: 17)
        
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}

