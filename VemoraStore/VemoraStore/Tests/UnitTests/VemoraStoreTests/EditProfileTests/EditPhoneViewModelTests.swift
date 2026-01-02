//
//  EditPhoneViewModelTests.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 16.10.2025.
//

import XCTest
import Combine
@testable import VemoraStore

final class EditPhoneViewModelTests: XCTestCase {
    
    private var repo: ProfileRepositorySpy_EditPhone!
    private var validator: ValidatorFake!
    private var checkout: CheckoutStorageMock!
    private var vm: EditPhoneViewModel!
    private var bag: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        repo = ProfileRepositorySpy_EditPhone()
        validator = ValidatorFake()
        checkout = CheckoutStorageMock()
        vm = EditPhoneViewModel(
            profileRepository: repo,
            validator: validator,
            userId: "uid-1",
            checkoutStorage: checkout
        )
        bag = []
    }
    
    override func tearDown() {
        bag = nil
        vm = nil
        checkout = nil
        validator = nil
        repo = nil
        super.tearDown()
    }
    
    // MARK: - Helpers
    
    private func rule(valid: Bool, message: String? = nil) -> ValidatorFake.Rule {
        { _ in
            ValidationResult(
                isValid: valid,
                messages: message.map {
                    [$0]
                } ?? [])
        }
    }
    
    // MARK: - Initial bind
    
    func test_initial_binds_first_profile_value_and_updates_checkout_storage() throws {
        let profile = UserProfile(
            userId: "uid-1",
            name: "User",
            email: "m@ex.com",
            phone: "+79990000000",
            updatedAt: Date()
        )
        
        let phone = try awaitValue(
            vm.phonePublisher,
            where: { $0 == "+79990000000" },
            after: { self.repo.send(profile) }
        )
        XCTAssertEqual(phone, "+79990000000")
        XCTAssertEqual(vm.currentPhone, "+79990000000")
        XCTAssertNil(vm.currentError)
        XCTAssertEqual(checkout.savedReceiverPhoneE164, "+79990000000")
    }
    
    // MARK: - Validation / error publishing
    
    func test_phoneError_emits_validator_message() throws {
        validator.setRule(
            for: .phone,
            rule: rule(valid: false, message: "bad phone")
        )
        
        let err = try awaitValue(
            vm.phoneError,
            where: { $0 == "bad phone" },
            after: { self.vm.setPhone("+7000") }
        )
        XCTAssertEqual(err, "bad phone")
        XCTAssertEqual(vm.currentError, "bad phone")
    }
    
    // MARK: - isSubmitEnabled logic
    
    func test_isSubmitEnabled_true_when_valid_and_changed() throws {
        repo.send(UserProfile(
            userId: "uid-1",
            name: "U",
            email: "e@x",
            phone: "+70000000001",
            updatedAt: Date())
        )
        validator.setRule(for: .phone, rule: rule(valid: true))
        
        let enabled = try awaitValue(
            vm.isSubmitEnabled,
            where: { $0 == true },
            after: { self.vm.setPhone("+70000000002") }
        )
        XCTAssertTrue(enabled)
    }
    
    func test_isSubmitEnabled_false_when_same_after_trim_or_empty() throws {
        repo.send(UserProfile(
            userId: "uid-1",
            name: "U",
            email: "e@x",
            phone: "+71111111111",
            updatedAt: Date())
        )
        validator.setRule(for: .phone, rule: rule(valid: true))
        
        let same = try awaitValue(
            vm.isSubmitEnabled,
            where: { $0 == false },
            after: { self.vm.setPhone("  +71111111111  ") }
        )
        XCTAssertFalse(same)
        
        let empty = try awaitValue(
            vm.isSubmitEnabled,
            where: { $0 == false },
            after: { self.vm.setPhone("   ") }
        )
        XCTAssertFalse(empty)
    }
    
    func test_isSubmitEnabled_false_when_invalid_even_if_changed() throws {
        repo.send(UserProfile(
            userId: "uid-1",
            name: "U",
            email: "e@x",
            phone: "+72222222222",
            updatedAt: Date())
        )
        validator.setRule(
            for: .phone,
            rule: rule(valid: false, message: "bad")
        )
        
        let disabled = try awaitValue(
            vm.isSubmitEnabled,
            where: { $0 == false },
            after: { self.vm.setPhone("+73333333333") }
        )
        XCTAssertFalse(disabled)
        
        let err = try awaitValue(vm.phoneError, where: { $0 == "bad" })
        XCTAssertEqual(err, "bad")
    }
    
    // MARK: - submit
    
    func test_submit_calls_updatePhone_updates_checkout_and_disables_submit_after() async throws {
        repo.send(UserProfile(
            userId: "uid-1",
            name: "U",
            email: "e@x",
            phone: "+70000000001",
            updatedAt: Date())
        )
        validator.setRule(
            for: .phone,
            rule: rule(valid: true)
        )
        
        _ = try awaitValue(
            vm.phonePublisher,
            where: { $0 == "+70000000005" },
            after: { self.vm.setPhone("+70000000005") }
        )
        
        _ = try awaitValue(vm.isSubmitEnabled, where: { $0 == true })
        
        try await vm.submit()
        
        XCTAssertEqual(repo.updatePhoneCalls, 1)
        XCTAssertEqual(repo.lastUpdatePhone?.uid, "uid-1")
        XCTAssertEqual(repo.lastUpdatePhone?.phone, "+70000000005")
        XCTAssertEqual(checkout.savedReceiverPhoneE164, "+70000000005")
        
        let canSubmitAfter: Bool = try awaitValue(vm.isSubmitEnabled.first())
        XCTAssertFalse(canSubmitAfter)
    }
    
    func test_submit_does_nothing_when_invalid() async throws {
        let profile = UserProfile(
            userId: "uid-1",
            name: "U",
            email: "e@x",
            phone: "+70000000001",
            updatedAt: Date()
        )
        
        _ = try awaitValue(
            vm.phonePublisher,
            where: { $0 == "+70000000001" },
            after: { self.repo.send(profile) }
        )
        XCTAssertEqual(checkout.savedReceiverPhoneE164, "+70000000001")
        
        validator.setRule(for: .phone, rule: rule(valid: false, message: "bad"))
        vm.setPhone("+70000000009")
        try await vm.submit()
        
        XCTAssertEqual(repo.updatePhoneCalls, 0)
        XCTAssertEqual(checkout.savedReceiverPhoneE164, "+70000000001") }
}
