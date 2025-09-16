//
//  CLGeocodingService.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 16.09.2025.
//

import Foundation
import CoreLocation
import MapKit

final class CLGeocodingService: GeocodingServiceProtocol {
    private let geocoder = CLGeocoder()
    
    func reverseGeocode(_ location: CLLocation,
                        locale: Locale,
                        completion: @escaping (MKPlacemark?) -> Void) {
        geocoder.cancelGeocode()
        geocoder.reverseGeocodeLocation(location, preferredLocale: locale) { placemarks, _ in
            completion(placemarks?.first.map { MKPlacemark(placemark: $0) })
        }
    }
}
