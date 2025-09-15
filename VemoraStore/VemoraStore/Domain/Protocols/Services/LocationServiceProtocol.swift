//
//  LocationServiceProtocol.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 29.08.2025.
//

import Foundation
import Combine
import CoreLocation

protocol LocationServiceProtocol {
    var locationPublisher: AnyPublisher<CLLocationCoordinate2D, Never> { get }
    func request()
}
