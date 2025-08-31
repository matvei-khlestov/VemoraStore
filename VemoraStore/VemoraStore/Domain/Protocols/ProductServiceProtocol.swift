//
//  ProductServiceProtocol.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 29.08.2025.
//

import Foundation
import Combine

protocol ProductServiceProtocol {
    func products() -> AnyPublisher<[Product], Error>
    func products(in categoryId: String) -> AnyPublisher<[Product], Error>
    func categories() -> AnyPublisher<[Category], Error>
}
