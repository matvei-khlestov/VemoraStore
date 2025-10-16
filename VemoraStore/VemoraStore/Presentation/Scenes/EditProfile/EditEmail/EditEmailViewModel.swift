//
//  EditEmailViewModel.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 24.09.2025.
//

import Foundation
import Combine

final class EditEmailViewModel: EditEmailViewModelProtocol {
    
    // MARK: - Deps
    
    private let profileRepository: ProfileRepository
    private let userId: String
    private let validator: FormValidatingProtocol
    
    // MARK: - State
    
    @Published private var email: String = ""
    @Published private var _emailError: String? = nil
    
    private var initialEmail: String = ""
    private var bag = Set<AnyCancellable>()
    
    // MARK: - Init
    
    init(
        profileRepository: ProfileRepository,
        validator: FormValidatingProtocol,
        userId: String
    ) {
        self.profileRepository = profileRepository
        self.validator = validator
        self.userId = userId

        bindProfile()
    }
    
    // MARK: - Outputs
    
    var currentEmail: String { email }
    var currentError: String? { _emailError }
    
    var emailError: AnyPublisher<String?, Never> {
        $_emailError.eraseToAnyPublisher()
    }
    
    var emailPublisher: AnyPublisher<String, Never> {
        $email.eraseToAnyPublisher()
    }
    
    var isSubmitEnabled: AnyPublisher<Bool, Never> {
        let isValid = $_emailError.map { $0 == nil }
        
        let isChanged = $email
            .map { [weak self] new in
                guard let self else { return false }
                let a = new.trimmingCharacters(in: .whitespacesAndNewlines)
                let b = self.initialEmail.trimmingCharacters(in: .whitespacesAndNewlines)
                return !a.isEmpty && a != b
            }
        
        return Publishers.CombineLatest(isValid, isChanged)
            .map { $0 && $1 }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
    
    // MARK: - Inputs
    
    func setEmail(_ value: String) {
        email = value
    }
    
    // MARK: - Actions
    
    func submit() async throws {
        guard validator.validate(email, for: .email).isValid else { return }
        
        try await profileRepository.updateEmail(uid: userId, email: email)
        
        await MainActor.run {
            self.initialEmail = self.email
        }
    }
    
    private func bindProfile() {
        profileRepository.observeProfile()
            .compactMap { $0 }
            .prefix(1)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] profile in
                guard let self else { return }
                self.initialEmail = profile.email
                self.email = profile.email
            }
            .store(in: &bag)
        
        $email
            .removeDuplicates()
            .map {
                [validator] in validator.validate($0, for: .email).message
            }
            .assign(to: &$_emailError)
    }
}

// MARK: - BaseEditFieldViewModelProtocol

extension EditEmailViewModel: BaseEditFieldViewModelProtocol {
    var currentValue: String { currentEmail }
    var error: AnyPublisher<String?, Never> { emailError }
    func setValue(_ value: String) { setEmail(value) }
}
