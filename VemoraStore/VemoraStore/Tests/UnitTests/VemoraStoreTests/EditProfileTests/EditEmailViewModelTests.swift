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
    private var validator: ValidatorFake!
    private var vm: EditEmailViewModel!
    private var bag: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        repo = ProfileRepositorySpy_EditEmail()
        validator = ValidatorFake()
        vm = EditEmailViewModel(
            profileRepository: repo,
            validator: validator,
            userId: "uid-1"
        )
        bag = []
    }
    
    override func tearDown() {
        bag = nil
        vm = nil
        validator = nil
        repo = nil
        super.tearDown()
    }
    
    // MARK: - Helpers
    
    private func rule(valid: Bool, message: String? = nil) -> ValidatorFake.Rule {
        {
            _ in ValidationResult(
                isValid: valid,
                messages: message.map {
                    [$0]
                } ?? []
            )
        }
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
        repo.send(UserProfile(
            userId: "uid-1",
            name: "U",
            email: "old@ex.com",
            phone: "",
            updatedAt: Date())
        )
        validator.setRule(
            for: .email,
            rule: rule(valid: true)
        )
        
        let enabled = try awaitValue(
            vm.isSubmitEnabled,
            where: { $0 == true },
            after: { self.vm.setEmail("new@ex.com") }
        )
        XCTAssertTrue(enabled)
    }
    
    func test_isSubmitEnabled_false_when_same_after_trim_or_empty() throws {
        repo.send(UserProfile(
            userId: "uid-1",
            name: "U",
            email: "same@ex.com",
            phone: "",
            updatedAt: Date())
        )
        validator.setRule(
            for: .email,
            rule: rule(valid: true)
        )
        
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
        repo.send(UserProfile(
            userId: "uid-1",
            name: "U",
            email: "old@ex.com",
            phone: "",
            updatedAt: Date())
        )
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
    
    // MARK: - submit
    
    func test_submit_calls_updateEmail_when_valid_and_updates_initialEmail() async throws {
        repo.send(UserProfile(
            userId: "uid-1",
            name: "U",
            email: "old@ex.com",
            phone: "",
            updatedAt: Date())
        )
        validator.setRule(
            for: .email,
            rule: rule(valid: true)
        )
        
        _ = try awaitValue(
            vm.emailPublisher,
            where: { $0 == "new@ex.com" },
            after: { self.vm.setEmail("new@ex.com") }
        )
        
        _ = try awaitValue(vm.isSubmitEnabled, where: { $0 == true })
        
        try await vm.submit()
        
        XCTAssertEqual(repo.updateEmailCalls, 1)
        XCTAssertEqual(repo.lastUpdateEmail?.uid, "uid-1")
        XCTAssertEqual(repo.lastUpdateEmail?.email, "new@ex.com")
        
        let canSubmitAfter: Bool = try awaitValue(vm.isSubmitEnabled.first())
        XCTAssertFalse(canSubmitAfter)
    }
    
    func test_submit_does_nothing_when_invalid() async throws {
        repo.send(UserProfile(
            userId: "uid-1",
            name: "U",
            email: "old@ex.com",
            phone: "",
            updatedAt: Date())
        )
        validator.setRule(
            for: .email,
            rule: rule(valid: false, message: "bad")
        )
        
        vm.setEmail("new@ex.com")
        try await vm.submit()
        
        XCTAssertEqual(repo.updateEmailCalls, 0)
    }
}
