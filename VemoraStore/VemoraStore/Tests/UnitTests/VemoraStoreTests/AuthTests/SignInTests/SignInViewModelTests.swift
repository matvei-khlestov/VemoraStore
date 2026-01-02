//
//  SignInViewModelTests.swift
//  VemoraStoreTests
//
//  Created by Matvei Khlestov on 15.10.2025.
//

import XCTest
import Combine
@testable import VemoraStore

final class SignInViewModelTests: XCTestCase {
    
    private var auth: AuthServiceMock!
    private var validator: ValidatorFake!
    private var vm: SignInViewModel!
    private var bag: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        auth = AuthServiceMock()
        validator = ValidatorFake()
        vm = SignInViewModel(auth: auth, validator: validator)
        bag = []
    }
    
    override func tearDown() {
        bag = nil
        vm = nil
        validator = nil
        auth = nil
        super.tearDown()
    }
    
    // MARK: - Helpers
    
    private func makeEmailRule(valid: Bool, message: String? = nil) -> ValidatorFake.Rule {
        { _ in ValidationResult(isValid: valid, messages: message.map { [$0] } ?? []) }
    }
    
    private func makePasswordRule(valid: Bool, message: String? = nil) -> ValidatorFake.Rule {
        { _ in ValidationResult(isValid: valid, messages: message.map { [$0] } ?? []) }
    }
    
    // MARK: - Tests
    
    func test_isSubmitEnabled_true_when_email_and_password_valid() throws {
        validator.setRule(for: .email, rule: makeEmailRule(valid: true))
        validator.setRule(for: .password, rule: makePasswordRule(valid: true))

        let value: Bool = try awaitValue(
            vm.isSubmitEnabled,
            where: { $0 == true },
            after: {
                self.vm.setEmail("user@example.com")
                self.vm.setPassword("12345678")
            }
        )
        XCTAssertTrue(value)
    }

    func test_isSubmitEnabled_false_when_email_invalid() throws {
        validator.setRule(for: .email,    rule: makeEmailRule(valid: false, message: "bad email"))
        validator.setRule(for: .password, rule: makePasswordRule(valid: true))

        let isEnabled: Bool = try awaitValue(
            vm.isSubmitEnabled,
            where: { $0 == false },
            after: {
                self.vm.setEmail("oops")
                self.vm.setPassword("12345678")
            }
        )
        XCTAssertFalse(isEnabled)

        let emailErr: String? = try awaitValue(
            vm.emailError,
            where: { $0 == "bad email" },
            after: { }
        )
        XCTAssertEqual(emailErr, "bad email")
    }
    
    func test_signIn_calls_auth_when_valid() async throws {
        validator.setRule(for: .email, rule: makeEmailRule(valid: true))
        validator.setRule(for: .password, rule: makePasswordRule(valid: true))
        
        vm.setEmail("user@example.com")
        vm.setPassword("12345678")
        
        try await vm.signIn()
        
        XCTAssertEqual(auth.signInCalls, 1)
        XCTAssertEqual(auth.lastSignInEmail, "user@example.com")
        XCTAssertEqual(auth.lastSignInPassword, "12345678")
        XCTAssertEqual(auth.currentUserId, "mock_uid")
    }
    
    func test_signIn_does_not_call_auth_when_invalid() async throws {
        validator.setRule(for: .email, rule: makeEmailRule(valid: false))
        validator.setRule(for: .password, rule: makePasswordRule(valid: true))
        
        vm.setEmail("bad")
        vm.setPassword("12345678")
        
        try await vm.signIn()
        
        XCTAssertEqual(auth.signInCalls, 0)
        XCTAssertNil(auth.currentUserId)
    }
    
    func test_signIn_propagates_errors_from_auth() async {
        validator.setRule(for: .email, rule: makeEmailRule(valid: true))
        validator.setRule(for: .password, rule: makePasswordRule(valid: true))
        vm.setEmail("user@example.com")
        vm.setPassword("12345678")
        
        enum Dummy: Error { case failed }
        auth.signInResult = .failure(Dummy.failed)
        
        do {
            try await vm.signIn()
            XCTFail("Expected to throw")
        } catch {
            XCTAssertTrue(error is Dummy)
        }
    }
}
