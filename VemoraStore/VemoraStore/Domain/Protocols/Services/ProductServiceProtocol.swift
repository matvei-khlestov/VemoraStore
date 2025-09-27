//
//  ProductServiceProtocol.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 29.08.2025.
//

import Foundation
import Combine

protocol ProductServiceProtocol {
    func products() -> AnyPublisher<[ProductTest], Error>
    func products(in categoryId: String) -> AnyPublisher<[ProductTest], Error>
    func categories() -> AnyPublisher<[CategoryTest], Error>
}
