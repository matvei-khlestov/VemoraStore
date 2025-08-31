//
//  LocationService.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 29.08.2025.
//

import Foundation
import CoreLocation
import Combine

final class LocationService: NSObject, CLLocationManagerDelegate, LocationServiceProtocol {
    static let shared = LocationService()
    private let manager = CLLocationManager()
    private let subject = PassthroughSubject<CLLocationCoordinate2D, Never>()
    
    var locationPublisher: AnyPublisher<CLLocationCoordinate2D, Never> {
        subject.eraseToAnyPublisher()
    }
    
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func request() {
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let coord = locations.last?.coordinate {
            subject.send(coord)
        }
    }
}

