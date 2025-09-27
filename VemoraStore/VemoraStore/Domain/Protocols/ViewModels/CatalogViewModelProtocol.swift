//
//  CatalogViewModelProtocol.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 22.09.2025.
//

import Foundation
import Combine

protocol CatalogViewModelProtocol: AnyObject {
    // Ввод из UI
    var query: String { get set }
    
    // Текущие значения для data source
    var categories: [(title: String, count: Int, imageURL: URL?)] { get }
    var products: [ProductTest] { get }
    
    // Паблишеры для биндингов
    var categoriesPublisher: AnyPublisher<[(title: String, count: Int, imageURL: URL?)], Never> { get }
    var productsPublisher: AnyPublisher<[ProductTest], Never> { get }
    
    // Действия
    func reload()
}
