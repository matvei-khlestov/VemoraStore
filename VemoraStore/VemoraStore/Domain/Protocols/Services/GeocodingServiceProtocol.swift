//
//  GeocodingServiceProtocol.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 16.09.2025.
//

import Foundation
import CoreLocation
import MapKit

protocol GeocodingServiceProtocol: AnyObject {
    func reverseGeocode(_ location: CLLocation,
                        locale: Locale,
                        completion: @escaping (MKPlacemark?) -> Void)
}
