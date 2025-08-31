//
//  LoginViewModel.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 29.08.2025.
//

import Foundation
import Combine
import FactoryKit

final class LoginViewModel {
    
    // MARK: - Services
    private let authService: AuthServiceProtocol
    
    // MARK: - State
    @Published var email: String = ""
    @Published var password: String = ""
    
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var errorMessage: String?
    @Published private(set) var isAuthorized: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Init
    init(authService: AuthServiceProtocol = Container.shared.authService()) {
        self.authService = authService
        bind()
    }
    
    // MARK: - Private
    private func bind() {
        // Если у сервиса есть паблишер авторизации — можно слушать его
        authService.isAuthorizedPublisher
            .receive(on: DispatchQueue.main)
            .assign(to: &$isAuthorized)
    }
    
    // MARK: - Actions
    func login() {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Введите почту и пароль"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                try await authService.signIn(email: email, password: password)
                await MainActor.run {
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = "Ошибка входа: \(error.localizedDescription)"
                    self.isLoading = false
                }
            }
        }
    }
    
    func register() {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Введите почту и пароль"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                try await authService.signUp(email: email, password: password)
                await MainActor.run {
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = "Ошибка регистрации: \(error.localizedDescription)"
                    self.isLoading = false
                }
            }
        }
    }
    
    func logout() {
        do {
            try authService.signOut()
        } catch {
            errorMessage = "Ошибка выхода: \(error.localizedDescription)"
        }
    }
}
