//
//  EditPhoneViewModel.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 24.09.2025.
//

import Foundation
import Combine

final class EditPhoneViewModel: EditPhoneViewModelProtocol {
    
    // MARK: - Deps
    private let profile: ProfileServiceProtocol
    private let validator: AuthValidatingProtocol
    
    // MARK: - State
    @Published private var phone: String
    @Published private var _phoneError: String? = nil
    private var bag = Set<AnyCancellable>()
    
    // MARK: - Init
    init(profile: ProfileServiceProtocol, validator: AuthValidatingProtocol) {
        self.profile = profile
        self.validator = validator
        self.phone = profile.currentPhone
        
        // live validation
        $phone
            .map { [validator] in validator.validate($0, for: .phone).message }
            .assign(to: &$_phoneError)
    }
    
    // MARK: - Outputs
    var currentPhone: String { phone }
    
    var phoneError: AnyPublisher<String?, Never> { $_phoneError.eraseToAnyPublisher() }
    
    var isSubmitEnabled: AnyPublisher<Bool, Never> {
        let isValid = $_phoneError.map { $0 == nil }
        let isChanged = $phone
            .map { [initial = profile.currentPhone] in
                $0.trimmingCharacters(in: .whitespacesAndNewlines)
                != initial.trimmingCharacters(in: .whitespacesAndNewlines)
            }
        return Publishers.CombineLatest(isValid, isChanged)
            .map { $0 && $1 }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
    
    // MARK: - Inputs
    func setPhone(_ value: String) { phone = value }
    
    // MARK: - Actions
    func submit() async throws {
        guard validator.validate(phone, for: .phone).isValid else {
            throw NSError(
                domain: "EditPhone",
                code: 1,
                userInfo: [NSLocalizedDescriptionKey: "Проверьте корректность телефона"]
            )
        }
        try await profile.updatePhone(phone) // должен быть в формате +7XXXXXXXXXX
    }
}

// MARK: - BaseEditFieldViewModelProtocol

extension EditPhoneViewModel: BaseEditFieldViewModelProtocol {
    var currentValue: String { currentPhone }
    var error: AnyPublisher<String?, Never> { phoneError }
    func setValue(_ value: String) { setPhone(value) }
}
