//
//  MapPickerViewModelProtocol.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 16.09.2025.
//

import Foundation
import CoreLocation
import MapKit

protocol MapPickerViewModelProtocol: AnyObject {
    // Inputs (from VC)
    func setIsSheetEditing(_ isEditing: Bool)
    func onViewDidAppear()
    func onRegionDidChange(center: CLLocationCoordinate2D)
    func onLocateTapped()
    func onZoomIn(currentRegion: MKCoordinateRegion) -> MKCoordinateRegion
    func onZoomOut(currentRegion: MKCoordinateRegion) -> MKCoordinateRegion
    func onLocationAuthChanged(_ status: CLAuthorizationStatus, manager: CLLocationManager)
    func onLocationsUpdated(_ locations: [CLLocation], manager: CLLocationManager)
    func onLocationFailed(_ error: Error)
    
    // Outputs (callbacks to VC)
    var requestPresentAddressSheet: ((String?) -> Void)? { get set }
    var requestCenterMap: ((CLLocationCoordinate2D, CLLocationDistance) -> Void)? { get set }
    var updateAddressText: ((String) -> Void)? { get set }
}
