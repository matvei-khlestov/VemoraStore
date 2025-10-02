//
//  PhoneInputSheetViewModel.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 01.10.2025.
//

import Foundation
import Combine

final class PhoneInputSheetViewModel: PhoneInputSheetViewModelProtocol {
    
    // MARK: - Deps
    
    private let validator: FormValidatingProtocol
    
    // MARK: - State
    
    @Published private var _phone: String
    @Published private var _error: String? = nil
    
    var currentError: String? { _error }
    
    private var bag = Set<AnyCancellable>()
    
    // MARK: - Init
    
    init(initialPhone: String? = nil, validator: FormValidatingProtocol) {
        self.validator = validator
        self._phone = (initialPhone?.isEmpty == false) ? initialPhone! : ""
        
        $_phone
            .dropFirst()
            .sink { [weak self] value in
                guard let self else { return }
                if self._error != nil, self.validator.validate(value, for: .phone).isValid {
                    self._error = nil
                }
            }
            .store(in: &bag)
    }
    
    // MARK: - Outputs
    
    var phone: String { _phone }
    
    var phonePublisher: AnyPublisher<String, Never> {
        $_phone.eraseToAnyPublisher()
    }
    
    var errorPublisher: AnyPublisher<String?, Never> {
        $_error.eraseToAnyPublisher()
    }
    
    // MARK: - Inputs
    
    func setPhone(_ value: String) {
        _phone = value
    }
    
    // MARK: - Validation
    
    @discardableResult
    func validate() -> Bool {
        let result = validator.validate(_phone, for: .phone)
        _error = result.message
        return result.isValid
    }
}
