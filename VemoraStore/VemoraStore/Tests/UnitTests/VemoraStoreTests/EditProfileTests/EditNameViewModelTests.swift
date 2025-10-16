//
//  EditNameViewModelTests.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 16.10.2025.
//

import XCTest
import Combine
@testable import VemoraStore

final class EditNameViewModelTests: XCTestCase {
    
    private var repo: ProfileRepositorySpy_EditName!
    private var validator: ValidatorFake!
    private var vm: EditNameViewModel!
    private var bag: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        repo = ProfileRepositorySpy_EditName()
        validator = ValidatorFake()
        vm = EditNameViewModel(
            profileRepository: repo,
            userId: "uid-1",
            validator: validator
        )
        bag = []
        RunLoop.main.run(until: Date().addingTimeInterval(0.02))
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
            _ in ValidationResult(isValid: valid, messages: message.map { [$0] } ?? [])
        }
    }
    
    // MARK: - Initial bind
    
    func test_initial_binds_first_profile_value() throws {
        let profile = UserProfile(
            userId: "uid-1",
            name: "Matvei",
            email: "m@ex.com",
            phone: "+70000000000",
            updatedAt: Date()
        )
        
        let name = try awaitValue(
            vm.namePublisher,
            where: {
                $0 == "Matvei"
            },
            after: {
                self.repo.send(profile)
            }
        )
        XCTAssertEqual(name, "Matvei")
        XCTAssertEqual(vm.currentName, "Matvei")
        XCTAssertNil(vm.currentError)
    }
    
    // MARK: - Validation / error publishing
    
    func test_nameError_emits_validator_message() throws {
        validator.setRule(for: .name, rule: { _ in
            ValidationResult(isValid: false, messages: ["bad name"])
        })
        
        let err = try awaitValue(
            vm.nameError,
            where: { $0 == "bad name" },
            after: {
                self.vm.setName("X")
            }
        )
        XCTAssertEqual(err, "bad name")
        XCTAssertEqual(vm.currentError, "bad name")
    }
    
    // MARK: - isSubmitEnabled logic
    
    func test_isSubmitEnabled_true_when_valid_and_changed() throws {
        repo.send(UserProfile(
            userId: "uid-1",
            name: "John",
            email: "",
            phone: "",
            updatedAt: Date()
        ))
        RunLoop.main.run(until: Date().addingTimeInterval(0.02))
        
        validator.setRule(for: .name, rule: rule(valid: true))
        
        let enabled = try awaitValue(
            vm.isSubmitEnabled,
            where: { $0 == true },
            after: { self.vm.setName("Johnny") }
        )
        XCTAssertTrue(enabled)
    }
    
    func test_isSubmitEnabled_false_when_same_after_trim_or_empty() throws {
        repo.send(UserProfile(
            userId: "uid-1",
            name: "John",
            email: "",
            phone: "",
            updatedAt: Date()
        ))
        RunLoop.main.run(until: Date().addingTimeInterval(0.02))
        
        validator.setRule(for: .name, rule: rule(valid: true))
        
        let same = try awaitValue(
            vm.isSubmitEnabled,
            where: { $0 == false },
            after: { self.vm.setName("John") }
        )
        XCTAssertFalse(same)
        
        let empty = try awaitValue(
            vm.isSubmitEnabled,
            where: { $0 == false },
            after: { self.vm.setName("") }
        )
        XCTAssertFalse(empty)
    }
    
    func test_isSubmitEnabled_false_when_invalid_even_if_changed() throws {
        repo.send(UserProfile(userId: "uid-1", name: "John", email: "", phone: "", updatedAt: Date()))
        RunLoop.main.run(until: Date().addingTimeInterval(0.02))
        
        validator.setRule(for: .name, rule: rule(valid: false, message: "bad"))
        
        let disabled = try awaitValue(
            vm.isSubmitEnabled,
            where: { $0 == false },
            after: { self.vm.setName("Johnny") }
        )
        XCTAssertFalse(disabled)
        
        let err = try awaitValue(vm.nameError, where: { $0 == "bad" })
        XCTAssertEqual(err, "bad")
    }
    
    // MARK: - submit
    
    func test_submit_calls_updateName_when_valid_and_updates_initialName() async throws {
        repo.send(UserProfile(userId: "uid-1", name: "John", email: "", phone: "", updatedAt: Date()))
        try? await Task.sleep(nanoseconds: 20_000_000)
        
        validator.setRule(for: .name, rule: { _ in ValidationResult(isValid: true, messages: []) })
        
        _ = try awaitValue(
            vm.namePublisher,
            where: { $0 == "Jack" },
            after: { self.vm.setName("Jack") }
        )
        
        _ = try awaitValue(
            vm.isSubmitEnabled,
            where: { $0 == true }
        )
        
        try await vm.submit()
        
        XCTAssertEqual(repo.updateNameCalls, 1)
        XCTAssertEqual(repo.lastUpdateName?.uid, "uid-1")
        XCTAssertEqual(repo.lastUpdateName?.name, "Jack")
        
        let canSubmitAfter: Bool = try awaitValue(vm.isSubmitEnabled.first())
        XCTAssertFalse(canSubmitAfter)
    }
    
    func test_submit_does_nothing_when_invalid() async throws {
        repo.send(UserProfile(
            userId: "uid-1",
            name: "John",
            email: "",
            phone: "",
            updatedAt: Date()
        ))
        try? await Task.sleep(nanoseconds: 20_000_000)
        
        validator.setRule(for: .name, rule: rule(valid: false, message: "bad"))
        
        vm.setName("Jack")
        try await vm.submit()
        
        XCTAssertEqual(repo.updateNameCalls, 0)
    }
}
