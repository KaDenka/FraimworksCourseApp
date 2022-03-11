//
//  MapViewController.swift
//  FrameworksCourseApp
//
//  Created by Denis Kazarin on 10.03.2022.
//

import UIKit
import GoogleMaps
import CoreLocation

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
    let mapPath = GMSMutablePath()
    
   // var coordinates = CLLocationCoordinate2D(latitude: 55.7282982, longitude: 37.5779991)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureMap(locationManager.location!.coordinate)
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
            makeMapPath(locationsArray)
            
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
        locationManager.requestWhenInUseAuthorization()
    }
    
    func makeMapPath(_ points: [CLLocationCoordinate2D]) {
        points.forEach { coordinate in
            mapPath.add(coordinate)
        }
        let polyline = GMSPolyline(path: mapPath)
        polyline.strokeWidth = 5.0
        polyline.strokeColor = .systemCyan
        polyline.geodesic = true
        polyline.map = mapView
    }
    
    @IBAction func createMarkerButton(_ sender: Any) {
        guard let coordinate = locationManager.location?.coordinate else { return }
        
        //    marker == nil ? addMarker(coordinates) : removeMarker()
        addMarker(.autoMarker, coordinate)
        
    }
    
    
    @IBAction func updateLocationButton(_ sender: Any) {
        locationManager.requestLocation()
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
//        if geoCoder == nil {
//            geoCoder = CLGeocoder()
//        }
//        geoCoder?.reverseGeocodeLocation(location) { places, error in
//            print(places?.first)
//        }
        
        //configureMap(location.coordinate)
        mapView.camera = GMSCameraPosition(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude, zoom: 17)
        
        
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}

