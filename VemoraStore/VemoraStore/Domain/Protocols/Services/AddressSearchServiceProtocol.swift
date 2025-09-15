//
//  AddressSearchServiceProtocol.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 15.09.2025.
//

import Foundation
import MapKit

protocol AddressSearchServiceProtocol: AnyObject {
    // Текущее содержимое подсказок (для удобства)
    var completions: [MKLocalSearchCompletion] { get }
    // Коллбек обновления подсказок
    var onResultsChanged: (([MKLocalSearchCompletion]) -> Void)? { get set }
    
    // Регион подсказок
    func setRegion(_ region: MKCoordinateRegion?)
    
    // Поиск
    func updateQuery(_ text: String)
    func resolve(completion: MKLocalSearchCompletion,
                 fallback: String,
                 completion: @escaping (MKPlacemark, CLLocationCoordinate2D, String) -> Void)
    
    func resolveFreeText(_ query: String,
                         completion: @escaping (MKPlacemark, CLLocationCoordinate2D, String) -> Void)
}
