//
//  AddressConfirmSheetViewModelProtocol.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 15.09.2025.
//

import Foundation
import MapKit

protocol AddressConfirmSheetViewModelProtocol: AnyObject {
    var completions: [MKLocalSearchCompletion] { get }
    var region: MKCoordinateRegion? { get set }
    
    var onResultsChanged: (([MKLocalSearchCompletion]) -> Void)? { get set }
    var onResolvedAddress: ((String, CLLocationCoordinate2D) -> Void)? { get set }
    
    func updateQuery(_ text: String)
    func resolve(completion: MKLocalSearchCompletion)
    func resolveFreeText(_ query: String)
}
