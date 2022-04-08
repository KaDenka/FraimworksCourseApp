//
//  LocationManager.swift
//  FrameworksCourseApp
//
//  Created by Denis Kazarin on 08.04.2022.
//

import Foundation
import CoreLocation
import RxSwift
import RxCocoa

final class LocationManager: NSObject {
    
    static let shared = LocationManager()
    
    var coordinates = CLLocationCoordinate2D(latitude: 55.7282982, longitude: 37.5779991)
    let manager = CLLocationManager()
    let location: BehaviorRelay<CLLocation?> = BehaviorRelay(value: nil)
    
     override init() {
        super.init()
        configureLocationManager()
    }
    
    private func configureLocationManager() {
        manager.delegate = self
        manager.requestAlwaysAuthorization()
        manager.allowsBackgroundLocationUpdates = true
        manager.startMonitoringSignificantLocationChanges()
        manager.pausesLocationUpdatesAutomatically = false
        
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.location.accept(locations.last)
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}
