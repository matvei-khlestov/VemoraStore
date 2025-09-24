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

    private let profile: ProfileServiceProtocol
    private let validator: AuthValidatingProtocol

    // MARK: - State

    @Published private var email: String
    @Published private var _emailError: String? = nil

    private var bag = Set<AnyCancellable>()

    // MARK: - Init

    init(
        profile: ProfileServiceProtocol,
        validator: AuthValidatingProtocol
    ) {
        self.profile = profile
        self.validator = validator
        self.email = profile.currentEmail

        // live validation
        $email
            .map { [validator] in validator.validate($0, for: .email).message }
            .assign(to: &$_emailError)
    }

    // MARK: - Outputs

    var currentEmail: String { email }

    var emailError: AnyPublisher<String?, Never> { $_emailError.eraseToAnyPublisher() }

    var isSubmitEnabled: AnyPublisher<Bool, Never> {
        let isValid = $_emailError.map { $0 == nil }
        let isChanged = $email
            .map { [initial = profile.currentEmail] in
                $0.trimmingCharacters(in: .whitespacesAndNewlines)
                != initial.trimmingCharacters(in: .whitespacesAndNewlines)
            }

        return Publishers.CombineLatest(isValid, isChanged)
            .map { $0 && $1 }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    // MARK: - Inputs

    func setEmail(_ value: String) { email = value }

    // MARK: - Actions

    func submit() async throws {
        guard validator.validate(email, for: .email).isValid else {
            throw NSError(
                domain: "EditEmail",
                code: 1,
                userInfo: [NSLocalizedDescriptionKey: "Проверьте корректность e-mail"]
            )
        }
        try await profile.updateEmail(email)
    }
}

// MARK: - BaseEditFieldViewModelProtocol

extension EditEmailViewModel: BaseEditFieldViewModelProtocol {
    var currentValue: String { currentEmail }
    var error: AnyPublisher<String?, Never> { emailError }
    func setValue(_ value: String) { setEmail(value) }
}
