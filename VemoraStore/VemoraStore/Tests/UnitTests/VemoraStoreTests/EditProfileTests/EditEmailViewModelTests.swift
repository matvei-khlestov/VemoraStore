//
//  EditEmailViewModelTests.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 16.10.2025.
//

import XCTest
import Combine
@testable import VemoraStore

final class EditEmailViewModelTests: XCTestCase {
    
    private var repo: ProfileRepositorySpy_EditEmail!
    private var auth: AuthServiceMock!
    private var validator: ValidatorFake!
    private var vm: EditEmailViewModel!
    private var bag: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        repo = ProfileRepositorySpy_EditEmail()
        auth = AuthServiceMock()
        validator = ValidatorFake()
        vm = EditEmailViewModel(
            profileRepository: repo,
            authService: auth,
            validator: validator,
            userId: "uid-1"
        )
        bag = []
    }
    
    override func tearDown() {
        bag = nil
        vm = nil
        validator = nil
        auth = nil
        repo = nil
        super.tearDown()
    }
    
    // MARK: - Helpers
    
    private func rule(valid: Bool, message: String? = nil) -> ValidatorFake.Rule {
        {
            _ in ValidationResult(
                isValid: valid,
                messages: message.map { [$0] } ?? []
            )
        }
    }
    
    private func sendInitialProfile(email: String = "old@ex.com") {
        repo.send(UserProfile(
            userId: "uid-1",
            name: "U",
            email: email,
            phone: "",
            updatedAt: Date()
        ))
    }
    
    // MARK: - Initial bind
    
    func test_initial_binds_first_profile_value() throws {
        let profile = UserProfile(
            userId: "uid-1",
            name: "User",
            email: "m@ex.com",
            phone: "+70000000000",
            updatedAt: Date()
        )
        
        let email = try awaitValue(
            vm.emailPublisher,
            where: { $0 == "m@ex.com" },
            after: { self.repo.send(profile) }
        )
        XCTAssertEqual(email, "m@ex.com")
        XCTAssertEqual(vm.currentEmail, "m@ex.com")
        XCTAssertNil(vm.currentError)
    }
    
    // MARK: - Validation / error publishing
    
    func test_emailError_emits_validator_message() throws {
        validator.setRule(
            for: .email,
            rule: rule(valid: false, message: "bad email")
        )
        
        let err = try awaitValue(
            vm.emailError,
            where: { $0 == "bad email" },
            after: { self.vm.setEmail("x@ex.com") }
        )
        XCTAssertEqual(err, "bad email")
        XCTAssertEqual(vm.currentError, "bad email")
    }
    
    // MARK: - isSubmitEnabled logic
    
    func test_isSubmitEnabled_true_when_valid_and_changed() throws {
        sendInitialProfile(email: "old@ex.com")
        validator.setRule(for: .email, rule: rule(valid: true))
        
        let enabled = try awaitValue(
            vm.isSubmitEnabled,
            where: { $0 == true },
            after: { self.vm.setEmail("new@ex.com") }
        )
        XCTAssertTrue(enabled)
    }
    
    func test_isSubmitEnabled_false_when_same_after_trim_or_empty() throws {
        sendInitialProfile(email: "same@ex.com")
        validator.setRule(for: .email, rule: rule(valid: true))
        
        let same = try awaitValue(
            vm.isSubmitEnabled,
            where: { $0 == false },
            after: { self.vm.setEmail("same@ex.com") }
        )
        XCTAssertFalse(same)
        
        let empty = try awaitValue(
            vm.isSubmitEnabled,
            where: { $0 == false },
            after: { self.vm.setEmail("") }
        )
        XCTAssertFalse(empty)
    }
    
    func test_isSubmitEnabled_false_when_invalid_even_if_changed() throws {
        sendInitialProfile(email: "old@ex.com")
        validator.setRule(
            for: .email,
            rule: rule(valid: false, message: "bad")
        )
        
        let disabled = try awaitValue(
            vm.isSubmitEnabled,
            where: { $0 == false },
            after: { self.vm.setEmail("new@ex.com") }
        )
        XCTAssertFalse(disabled)
        
        let err = try awaitValue(vm.emailError, where: { $0 == "bad" })
        XCTAssertEqual(err, "bad")
    }
    
    // MARK: - submit (Step 1: password challenge)
    
    func test_submit_triggers_password_required_and_throws_challenge_error() async throws {
        sendInitialProfile(email: "old@ex.com")
        validator.setRule(for: .email, rule: rule(valid: true))
        vm.setEmail("new@ex.com")
        
        let exp = expectation(description: "onPasswordRequired called")
        vm.onPasswordRequired = { exp.fulfill() }
        
        do {
            try await vm.submit()
            XCTFail("Expected PasswordChallengeError.passwordRequired")
        } catch is EditEmailViewModel.PasswordChallengeError {
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
        
        await fulfillment(of: [exp], timeout: 1.0)
        
        XCTAssertEqual(auth.updateEmailCalls, 0)
        XCTAssertEqual(repo.updateEmailCalls, 0)
    }
    
    func test_submit_does_nothing_when_invalid_and_does_not_trigger_password_prompt() async throws {
        sendInitialProfile(email: "old@ex.com")
        validator.setRule(for: .email, rule: rule(valid: false, message: "bad"))
        vm.setEmail("new@ex.com")
        
        var passwordPromptCalls = 0
        vm.onPasswordRequired = { passwordPromptCalls += 1 }
        
        try await vm.submit()
        
        XCTAssertEqual(passwordPromptCalls, 0)
        XCTAssertEqual(auth.updateEmailCalls, 0)
        XCTAssertEqual(repo.updateEmailCalls, 0)
    }
    
    // MARK: - submit(withPassword:) (Step 2: update email)
    
    func test_submitWithPassword_calls_auth_and_repo_and_updates_initialEmail() async throws {
        validator.setRule(for: .email, rule: rule(valid: true))
        
        sendInitialProfile(email: "old@ex.com")
        
        _ = try awaitValue(vm.emailPublisher, where: { $0 == "old@ex.com" })
        
        vm.setEmail("new@ex.com")
        
        _ = try awaitValue(vm.isSubmitEnabled, where: { $0 == true })
        
        try await vm.submit(withPassword: "123456")
        
        XCTAssertEqual(auth.updateEmailCalls, 1)
        XCTAssertEqual(auth.lastUpdateEmailNewEmail, "new@ex.com")
        XCTAssertEqual(auth.lastUpdateEmailCurrentPassword, "123456")
        
        XCTAssertEqual(repo.updateEmailCalls, 1)
        XCTAssertEqual(repo.lastUpdateEmail?.uid, "uid-1")
        XCTAssertEqual(repo.lastUpdateEmail?.email, "new@ex.com")
        
        let canSubmitAfter: Bool = try awaitValue(vm.isSubmitEnabled, where: { $0 == false })
        XCTAssertFalse(canSubmitAfter)
    }
    
    func test_submitWithPassword_does_nothing_when_invalid() async throws {
        sendInitialProfile(email: "old@ex.com")
        validator.setRule(for: .email, rule: rule(valid: false, message: "bad"))
        vm.setEmail("new@ex.com")
        
        try await vm.submit(withPassword: "123456")
        
        XCTAssertEqual(auth.updateEmailCalls, 0)
        XCTAssertEqual(repo.updateEmailCalls, 0)
    }
    
    func test_submitWithPassword_propagates_auth_error_and_does_not_update_repo() async throws {
        struct TestError: Error {}

        var latestIsSubmitEnabled: Bool?
        vm.isSubmitEnabled
            .sink { latestIsSubmitEnabled = $0 }
            .store(in: &bag)

        validator.setRule(for: .email, rule: rule(valid: true))

        _ = try awaitValue(
            vm.emailPublisher,
            where: { $0 == "old@ex.com" },
            after: { self.sendInitialProfile(email: "old@ex.com") }
        )

        vm.setEmail("new@ex.com")

        _ = try awaitValue(vm.isSubmitEnabled, where: { $0 == true })

        auth.updateEmailResult = .failure(TestError())

        do {
            try await vm.submit(withPassword: "123456")
            XCTFail("Expected error")
        } catch is TestError {
            // ok
        } catch {
            XCTFail("Unexpected error: \(error)")
        }

        XCTAssertEqual(auth.updateEmailCalls, 1)
        XCTAssertEqual(repo.updateEmailCalls, 0)
        XCTAssertEqual(latestIsSubmitEnabled, true)
    }
    
    func test_submitWithPassword_propagates_repo_error_after_auth_success() async throws {
        struct TestError: Error {}

        validator.setRule(for: .email, rule: rule(valid: true))

        _ = try awaitValue(
            vm.emailPublisher,
            where: { $0 == "old@ex.com" },
            after: { self.sendInitialProfile(email: "old@ex.com") }
        )

        vm.setEmail("new@ex.com")
        _ = try awaitValue(vm.isSubmitEnabled, where: { $0 == true })

        repo.updateEmailResult = .failure(TestError())

        do {
            try await vm.submit(withPassword: "123456")
            XCTFail("Expected error")
        } catch is TestError {
            // ok
        } catch {
            XCTFail("Unexpected error: \(error)")
        }

        XCTAssertEqual(auth.updateEmailCalls, 1)
        XCTAssertEqual(repo.updateEmailCalls, 1)

        let enabledAfter = try awaitValue(vm.isSubmitEnabled, where: { $0 == true })
        XCTAssertTrue(enabledAfter)
    }
}
