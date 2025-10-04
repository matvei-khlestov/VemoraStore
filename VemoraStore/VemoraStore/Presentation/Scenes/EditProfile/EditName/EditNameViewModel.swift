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
    
    private let repos: RepositoryFactoryProtocol
    private let userId: String
    private let validator: FormValidatingProtocol
    
    // MARK: - State
    
    @Published private var name: String = ""
    @Published private var _nameError: String? = nil
    
    private var initialName: String = ""
    private var bag = Set<AnyCancellable>()
    
    // MARK: - Init
    
    init(
        repos: RepositoryFactoryProtocol,
        userId: String,
        validator: FormValidatingProtocol
    ) {
        self.repos = repos
        self.userId = userId
        self.validator = validator
        
        bindProfile()
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
            .map { [weak self] new in
                guard let self else { return false }
                let a = new.trimmingCharacters(in: .whitespacesAndNewlines)
                let b = self.initialName.trimmingCharacters(in: .whitespacesAndNewlines)
                return !a.isEmpty && a != b
            }
        
        return Publishers.CombineLatest(isValid, isChanged)
            .map { $0 && $1 }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
    
    // MARK: - Inputs
    
    func setName(_ value: String) {
        name = value
    }
    
    // MARK: - Actions
    
    func submit() async throws {
        // финальная проверка перед отправкой
        guard validator.validate(name, for: .name).isValid else {
            throw NSError(
                domain: "EditName",
                code: 1,
                userInfo: [NSLocalizedDescriptionKey: "Проверьте корректность имени"]
            )
        }
        
        try await repos
            .profileRepository(for: userId)
            .updateName(uid: userId, name: name)
        
        await MainActor.run {
            self.initialName = self.name
        }
    }
    
    private func bindProfile() {
        let repo = repos.profileRepository(for: userId)
        
        repo.observeProfile()
            .compactMap { $0 }
            .prefix(1)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] profile in
                guard let self else { return }
                self.initialName = profile.name
                self.name = profile.name
            }
            .store(in: &bag)
        
        $name
            .removeDuplicates()
            .map { [validator] in validator.validate($0, for: .name).message }
            .assign(to: &$_nameError)
    }
}

// MARK: - BaseEditFieldViewModelProtocol

extension EditNameViewModel: BaseEditFieldViewModelProtocol {
    var currentValue: String { currentName }
    var error: AnyPublisher<String?, Never> { nameError }
    func setValue(_ value: String) { setName(value) }
}
