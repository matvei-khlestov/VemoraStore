//
//  AddressSearchService.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 15.09.2025.
//

// Core/Location/AddressSearchService.swift
import Foundation
import MapKit

final class AddressSearchService: NSObject, AddressSearchServiceProtocol {
    private let completer = MKLocalSearchCompleter()
    private(set) var region: MKCoordinateRegion?
    
    // MARK: - Outputs
    var onResultsChanged: (([MKLocalSearchCompletion]) -> Void)?
    
    // MARK: - State
    private(set) var completions: [MKLocalSearchCompletion] = []
    
    override init() {
        super.init()
        completer.delegate = self
        completer.resultTypes = [.address]
    }
    
    func setRegion(_ region: MKCoordinateRegion?) {
        self.region = region
        completer.region = region ?? completer.region
    }
    
    func updateQuery(_ text: String) {
        completer.queryFragment = text.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func resolve(completion: MKLocalSearchCompletion,
                 fallback: String,
                 completion handler: @escaping (MKPlacemark, CLLocationCoordinate2D, String) -> Void) {
        let request = MKLocalSearch.Request(completion: completion)
        if let region { request.region = region }
        MKLocalSearch(request: request).start { response, error in
            guard error == nil, let item = response?.mapItems.first else { return }
            handler(item.placemark, item.placemark.coordinate, fallback)
        }
    }
    
    func resolveFreeText(_ query: String,
                         completion handler: @escaping (MKPlacemark, CLLocationCoordinate2D, String) -> Void) {
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !q.isEmpty else { return }
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = q
        if let region { request.region = region }
        MKLocalSearch(request: request).start { response, error in
            guard error == nil, let item = response?.mapItems.first else { return }
            handler(item.placemark, item.placemark.coordinate, q)
        }
    }
}

// MARK: - MKLocalSearchCompleterDelegate
extension AddressSearchService: MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        completions = completer.results
        onResultsChanged?(completions)
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        completions = []
        onResultsChanged?(completions)
    }
}
