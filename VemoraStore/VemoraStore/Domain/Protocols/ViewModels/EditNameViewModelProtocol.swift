//
//  EditNameViewModelProtocol.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 24.09.2025.
//

import Foundation
import Combine

protocol EditNameViewModelProtocol: BaseEditFieldViewModelProtocol, AnyObject {
    var nameError: AnyPublisher<String?, Never> { get }
    var currentName: String { get }
    func setName(_ value: String)
}
