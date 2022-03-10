//
//  MapViewController.swift
//  FrameworksCourseApp
//
//  Created by Denis Kazarin on 10.03.2022.
//

import UIKit
import GoogleMaps

class MapViewController: UIViewController {

    @IBOutlet weak var mapView: GMSMapView!
    
    var marker: GMSMarker?
    let coordinates = CLLocationCoordinate2D(latitude: 55.7282982, longitude: 37.5779991)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        configureMap()
    }
    
    override func viewWillAppear(_ animated: Bool) {
       // addMarker()
    }
    
    func addMarker() {
        marker = GMSMarker(position: coordinates)
        marker?.icon = GMSMarker.markerImage(with: .systemPink)
        marker?.map = mapView
    }
    
    func configureMap() {
        let cameraPosition = GMSCameraPosition.camera(withTarget: coordinates, zoom: 17)
        mapView.camera = cameraPosition
    }

    @IBAction func createMarkerButton(_ sender: Any) {
        addMarker()
    }
    
}

