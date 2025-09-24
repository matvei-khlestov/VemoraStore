//
//  EditNameViewModelProtocol.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 24.09.2025.
//

import Foundation
import Combine

protocol EditNameViewModelProtocol: AnyObject {
    var nameError: AnyPublisher<String?, Never> { get }
    var isSubmitEnabled: AnyPublisher<Bool, Never> { get }
    var currentName: String { get }
    func submit() async throws
    func setName(_ value: String)
}
