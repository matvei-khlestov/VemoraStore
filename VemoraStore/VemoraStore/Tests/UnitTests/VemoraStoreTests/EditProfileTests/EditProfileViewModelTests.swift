//
//  EditProfileViewModelTests.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 16.10.2025.
//

import XCTest
import Combine
@testable import VemoraStore

final class EditProfileViewModelTests: XCTestCase {
    
    private var avatar: AvatarStorageMock!
    private var repo: ProfileRepositoryStub!
    private var checkout: CheckoutStorageMock!
    private var vm: EditProfileViewModel!
    private var bag: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        avatar = AvatarStorageMock()
        repo = ProfileRepositoryStub()
        checkout = CheckoutStorageMock()
        vm = EditProfileViewModel(
            avatarStorage: avatar,
            profileRepository: repo,
            userId: "uid-1",
            checkoutStorage: checkout
        )
        bag = []
        
        RunLoop.main.run(until: Date().addingTimeInterval(0.02))
    }
    
    override func tearDown() {
        bag = nil
        vm = nil
        checkout = nil
        repo = nil
        avatar = nil
        super.tearDown()
    }
    
    // MARK: - Initial placeholders
    
    func test_initial_placeholders_when_profile_nil() throws {
        let name = try awaitValue(vm.namePublisher.first())
        let email = try awaitValue(vm.emailPublisher.first())
        let phone = try awaitValue(vm.phonePublisher.first())
        
        XCTAssertEqual(name,  "—")
        XCTAssertEqual(email, "—")
        XCTAssertEqual(phone, "—")
    }
    
    // MARK: - Profile propagation
    
    func test_updates_name_email_phone_on_profile_change_and_saves_phone_to_checkout() throws {
        XCTAssertNil(checkout.savedReceiverPhoneE164)
        
        let newName  = "Matvei"
        let newEmail = "matvei@example.com"
        let newPhone = "+79991234567"
        
        // ждём имя
        let name = try awaitValue(
            vm.namePublisher,
            where: { $0 == newName },
            after: {
                self.repo.send(
                    UserProfile(
                        userId: "uid-1",
                        name: newName,
                        email: newEmail,
                        phone: newPhone,
                        updatedAt: Date()
                    )
                )
            }
        )
        XCTAssertEqual(name, newName)
        let email = try awaitValue(vm.emailPublisher, where: {
            $0 == newEmail
        })
        XCTAssertEqual(email, newEmail)
        let phone = try awaitValue(vm.phonePublisher, where: {
            $0 == newPhone
        })
        XCTAssertEqual(phone, newPhone)
        XCTAssertEqual(checkout.savedReceiverPhoneE164, newPhone)
    }
    
    func test_empty_or_dash_phone_does_not_override_checkout() throws {
        checkout.savedReceiverPhoneE164 = "+71111111111"
        
        _ = try awaitValue(
            vm.phonePublisher,
            where: { $0 == "—" },
            after: {
                self.repo.send(
                    UserProfile(
                        userId: "uid-1",
                        name: "N",
                        email: "e@x",
                        phone: "",
                        updatedAt: Date()
                    )
                )
            }
        )
        XCTAssertEqual(checkout.savedReceiverPhoneE164, "+71111111111")
        
        _ = try awaitValue(
            vm.namePublisher,
            where: { $0 == "N" },
            after: {
                self.repo.send(
                    UserProfile(
                        userId: "uid-1",
                        name: "N",
                        email: "e@x",
                        phone: "—",
                        updatedAt: Date()
                    )
                )
            }
        )
        XCTAssertEqual(checkout.savedReceiverPhoneE164, "+71111111111")
    }
    
    // MARK: - Avatar
    
    func test_loadAvatarData_reads_from_storage_and_publishes() throws {
        let data = Data([1,2,3,4])
        avatar.stubData = data
        
        let received = try awaitValue(
            vm.avatarDataPublisher,
            where: { $0 == data },
            after: { self.vm.loadAvatarData() }
        )
        XCTAssertEqual(received, data)
    }
    
    func test_saveAvatarData_saves_to_storage_and_publishes() async throws {
        let data = Data([9,8,7])
        
        try await vm.saveAvatarData(data)
        
        XCTAssertEqual(avatar.stubData, data)
        
        let published = try awaitValue(vm.avatarDataPublisher.first())
        XCTAssertEqual(published, data)
    }
}
