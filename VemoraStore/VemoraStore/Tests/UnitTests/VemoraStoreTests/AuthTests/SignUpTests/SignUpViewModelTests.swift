//
//  SignUpViewModelTests.swift
//  VemoraStoreTests
//
//  Created by Matvei Khlestov on 16.10.2025.
//

import XCTest
import Combine
@testable import VemoraStore

final class SignUpViewModelTests: XCTestCase {
    
    private var auth: AuthServiceMock!
    private var validator: ValidatorFake!
    private var profileRepo: ProfileRepositoryMock!
    private var vm: SignUpViewModel!
    private var bag: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        auth = AuthServiceMock()
        validator = ValidatorFake()
        profileRepo = ProfileRepositoryMock()
        vm = SignUpViewModel(
            auth: auth,
            validator: validator,
            makeProfileRepository: { _ in self.profileRepo }
        )
        bag = []
    }
    
    override func tearDown() {
        bag = nil
        vm = nil
        profileRepo = nil
        validator = nil
        auth = nil
        super.tearDown()
    }
    
    // MARK: - Helpers
    
    private func makeRule(valid: Bool, message: String? = nil) -> ValidatorFake.Rule {
        { _ in ValidationResult(isValid: valid, messages: message.map { [$0] } ?? []) }
    }
    
    // MARK: - Tests
    
    // SignUpViewModelTests.swift

    func test_isSubmitEnabled_true_when_all_valid_and_agreed() throws {
        validator.setRule(for: .name,     rule: makeRule(valid: true))
        validator.setRule(for: .email,    rule: makeRule(valid: true))
        validator.setRule(for: .password, rule: makeRule(valid: true))

        // ждём именно true
        let value: Bool = try awaitValue(vm.isSubmitEnabled, where: { $0 == true }) {
            self.vm.setName("John")
            self.vm.setEmail("john@example.com")
            self.vm.setPassword("12345678")
            self.vm.setAgreement(true)
        }
        XCTAssertTrue(value)
    }

    func test_isSubmitEnabled_false_when_any_invalid() throws {
        validator.setRule(for: .name,     rule: makeRule(valid: false, message: "bad name"))
        validator.setRule(for: .email,    rule: makeRule(valid: true))
        validator.setRule(for: .password, rule: makeRule(valid: true))

        let value: Bool = try awaitValue(vm.isSubmitEnabled, where: { $0 == false }) {
            self.vm.setName("") // invalid
            self.vm.setEmail("john@example.com")
            self.vm.setPassword("12345678")
            self.vm.setAgreement(true)
        }
        XCTAssertFalse(value)

        let err: String? = try awaitValue(vm.nameError, where: { $0 == "bad name" }) { }
        XCTAssertEqual(err, "bad name")
    }

    func test_isSubmitEnabled_false_when_not_agreed() throws {
        validator.setRule(for: .name,     rule: makeRule(valid: true))
        validator.setRule(for: .email,    rule: makeRule(valid: true))
        validator.setRule(for: .password, rule: makeRule(valid: true))

        let value: Bool = try awaitValue(vm.isSubmitEnabled, where: { $0 == false }) {
            self.vm.setName("John")
            self.vm.setEmail("john@example.com")
            self.vm.setPassword("12345678")
            self.vm.setAgreement(false)
        }
        XCTAssertFalse(value)

        let err: String? = try awaitValue(
            vm.agreementError,
            where: { $0 == "Необходимо согласиться с политикой конфиденциальности" }
        ) { }
        XCTAssertEqual(err, "Необходимо согласиться с политикой конфиденциальности")
    }
    
    func test_signUp_calls_auth_and_ensureProfile_when_valid() async throws {
        validator.setRule(for: .name,     rule: makeRule(valid: true))
        validator.setRule(for: .email,    rule: makeRule(valid: true))
        validator.setRule(for: .password, rule: makeRule(valid: true))
        
        auth.uidOnSignUp = "uid123"
        
        vm.setName("John")
        vm.setEmail("john@example.com")
        vm.setPassword("12345678")
        vm.setAgreement(true)
        
        try await vm.signUp()
        
        XCTAssertEqual(auth.signUpCalls, 1)
        XCTAssertEqual(auth.lastSignUpEmail, "john@example.com")
        XCTAssertEqual(auth.lastSignUpPassword, "12345678")
        XCTAssertEqual(auth.currentUserId, "uid123")
        
        XCTAssertEqual(profileRepo.ensureCalls, 1)
        XCTAssertEqual(profileRepo.lastEnsureArgs?.uid, "uid123")
        XCTAssertEqual(profileRepo.lastEnsureArgs?.name, "John")
        XCTAssertEqual(profileRepo.lastEnsureArgs?.email, "john@example.com")
    }
    
    func test_signUp_does_not_call_anything_when_invalid() async throws {
        validator.setRule(for: .name,     rule: makeRule(valid: false))
        validator.setRule(for: .email,    rule: makeRule(valid: true))
        validator.setRule(for: .password, rule: makeRule(valid: true))
        
        vm.setName("") // invalid
        vm.setEmail("john@example.com")
        vm.setPassword("12345678")
        vm.setAgreement(true)
        
        try await vm.signUp()
        
        XCTAssertEqual(auth.signUpCalls, 0)
        XCTAssertEqual(profileRepo.ensureCalls, 0)
    }
    
    func test_signUp_propagates_error_from_auth() async {
        validator.setRule(for: .name,     rule: makeRule(valid: true))
        validator.setRule(for: .email,    rule: makeRule(valid: true))
        validator.setRule(for: .password, rule: makeRule(valid: true))
        
        vm.setName("John")
        vm.setEmail("john@example.com")
        vm.setPassword("12345678")
        vm.setAgreement(true)
        
        enum Dummy: Error { case failed }
        auth.signUpResult = .failure(Dummy.failed)
        
        do {
            try await vm.signUp()
            XCTFail("Expected to throw")
        } catch {
            XCTAssertTrue(error is Dummy)
        }
    }
    
    func test_signUp_skips_profile_when_no_uid() async throws {
        validator.setRule(for: .name,     rule: makeRule(valid: true))
        validator.setRule(for: .email,    rule: makeRule(valid: true))
        validator.setRule(for: .password, rule: makeRule(valid: true))
        
        auth.uidOnSignUp = nil // важный случай
        
        vm.setName("John")
        vm.setEmail("john@example.com")
        vm.setPassword("12345678")
        vm.setAgreement(true)
        
        try await vm.signUp()
        
        XCTAssertEqual(auth.signUpCalls, 1)
        XCTAssertNil(auth.currentUserId)
        XCTAssertEqual(profileRepo.ensureCalls, 0)
    }
}
