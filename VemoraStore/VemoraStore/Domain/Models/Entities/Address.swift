//
//  Address.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 29.08.2025.
//

import Foundation
import CoreLocation

struct Address: Codable, Hashable {
    var street: String
    var city: String
    var lat: Double?
    var lon: Double?
}

extension Address {
    var coordinate: CLLocationCoordinate2D? {
        guard let lat, let lon else { return nil }
        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }
    
    init(street: String, city: String, coordinate: CLLocationCoordinate2D?) {
        self.street = street
        self.city = city
        self.lat = coordinate?.latitude
        self.lon = coordinate?.longitude
    }
}
