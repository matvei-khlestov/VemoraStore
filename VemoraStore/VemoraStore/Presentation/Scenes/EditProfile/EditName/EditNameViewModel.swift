//
//  EditNameViewModel.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 24.09.2025.
//

import Foundation
import Combine

final class EditNameViewModel: EditNameViewModelProtocol {
    
    // MARK: - Deps
    
    private let profile: ProfileServiceProtocol
    private let validator: FormValidatingProtocol
    
    // MARK: - State
    
    @Published private var name: String
    @Published private var _nameError: String? = nil
    private var bag = Set<AnyCancellable>()
    
    // MARK: - Init
    
    init(profile: ProfileServiceProtocol, validator: FormValidatingProtocol) {
        self.profile = profile
        self.validator = validator
        self.name = profile.currentName
        
        $name
            .removeDuplicates()
            .map { [validator] in validator.validate($0, for: .name).message }
            .assign(to: &$_nameError)
    }
    
    // MARK: - Outputs
    
    var currentName: String { name }
    var currentError: String? { _nameError }
    
    var nameError: AnyPublisher<String?, Never> {
        $_nameError.eraseToAnyPublisher()
    }
    
    var namePublisher: AnyPublisher<String, Never> {
        $name.eraseToAnyPublisher()
    }
    
    var isSubmitEnabled: AnyPublisher<Bool, Never> {
        let isValid = $_nameError.map { $0 == nil }
        let isChanged = $name
            .map { [initial = profile.currentName] in
                $0.trimmingCharacters(in: .whitespacesAndNewlines)
                != initial.trimmingCharacters(in: .whitespacesAndNewlines)
            }
        return Publishers.CombineLatest(isValid, isChanged)
            .map { $0 && $1 }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
    
    // MARK: - Inputs
    
    func setName(_ value: String) { name = value }
    
    // MARK: - Actions
    func submit() async throws {
        guard validator.validate(name, for: .name).isValid else {
            throw NSError(
                domain: "EditName",
                code: 1,
                userInfo: [
                    NSLocalizedDescriptionKey: "Проверьте корректность имени"
                ]
            )
        }
        try await profile.updateName(name)
    }
}

// MARK: - BaseEditFieldViewModelProtocol

extension EditNameViewModel: BaseEditFieldViewModelProtocol {
    var currentValue: String { currentName }
    var error: AnyPublisher<String?, Never> { nameError }
    func setValue(_ value: String) { setName(value) }
}
