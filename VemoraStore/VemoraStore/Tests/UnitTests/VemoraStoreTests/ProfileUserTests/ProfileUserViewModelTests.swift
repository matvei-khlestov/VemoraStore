//
//  ProfileUserViewModelTests.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 16.10.2025.
//

import XCTest
import Combine
@testable import VemoraStore

final class ProfileUserViewModelTests: XCTestCase {

    private var auth: AuthServiceMock!
    private var avatar: AvatarStorageMock!
    private var repo: ProfileRepositoryStub!
    private var vm: ProfileUserViewModel!
    private var bag: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        auth = AuthServiceMock()
        avatar = AvatarStorageMock()
        repo = ProfileRepositoryStub()
        vm = ProfileUserViewModel(
            auth: auth,
            avatarStorage: avatar,
            profileRepository: repo,
            userId: "uid-1"
        )
        bag = []
    }

    override func tearDown() {
        bag = nil
        vm = nil
        repo = nil
        avatar = nil
        auth = nil
        super.tearDown()
    }

    // MARK: - Rows / Table

    func test_rows_and_rowAccessor() {
        XCTAssertEqual(vm.rowsCount, 5)
        XCTAssertEqual(vm.rowsCount, vm.rows.count)

        XCTAssertEqual(vm.row(at: 0), .editProfile)
        XCTAssertEqual(vm.row(at: 1), .orders)
        XCTAssertEqual(vm.row(at: 2), .about)
        XCTAssertEqual(vm.row(at: 3), .contact)
        XCTAssertEqual(vm.row(at: 4), .privacy)

        XCTAssertNil(vm.row(at: -1))
        XCTAssertNil(vm.row(at: 5))
    }

    // MARK: - Publishers: initial placeholders

    func test_initial_placeholders_when_profile_nil() throws {
        let name = try awaitValue(vm.userNamePublisher.first())
        let email = try awaitValue(vm.userEmailPublisher.first())
        XCTAssertEqual(name, "—")
        XCTAssertEqual(email, "—")
    }

    // MARK: - Publishers: update after profile arrives

    func test_updates_name_and_email_on_profile_change() throws {
        let newName  = "Matvei"
        let newEmail = "matvei@example.com"

        let name: String = try awaitValue(
            vm.userNamePublisher,
            where: { $0 == newName },
            after: {
                self.repo.send(
                    UserProfile(
                        userId: "uid-1",
                        name: newName,
                        email: newEmail,
                        phone: "+70000000000",
                        updatedAt: Date()
                    )
                )
            }
        )
        XCTAssertEqual(name, newName)

        let email: String = try awaitValue(
            vm.userEmailPublisher,
            where: { $0 == newEmail }
        )
        XCTAssertEqual(email, newEmail)
    }

    // MARK: - Actions: logout / delete

    func test_logout_success() async throws {
        auth.signOutResult = .success(())
        try await vm.logout()
        XCTAssertNil(auth.currentUserId)
    }

    func test_logout_failure() async {
        enum Dummy: Error { case boom }
        auth.signOutResult = .failure(Dummy.boom)

        do {
            try await vm.logout()
            XCTFail("Expected to throw")
        } catch {
            XCTAssertTrue(error is Dummy)
        }
    }

    func test_deleteAccount_success() async throws {
        auth.currentUserId = "uid-1"
        auth.deleteResult = .success(())
        try await vm.deleteAccount()
        XCTAssertNil(auth.currentUserId)
    }

    func test_deleteAccount_failure() async {
        enum Dummy: Error { case boom }
        auth.deleteResult = .failure(Dummy.boom)

        do {
            try await vm.deleteAccount()
            XCTFail("Expected to throw")
        } catch {
            XCTAssertTrue(error is Dummy)
        }
    }

    // MARK: - Avatar

    func test_loadAvatarData_proxies_storage() {
        let data = Data([1,2,3])
        avatar.stubData = data
        XCTAssertEqual(vm.loadAvatarData(), data)
    }
}
