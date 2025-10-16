//
//  ProfileUserUITests.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 16.10.2025.
//

import XCTest

final class ProfileUserUITests: XCTestCase {
    
    @MainActor
    func test_profile_elements_exist_and_tap_actions() {
        let app = UITestUtils.makeApp(startScreen: "profile")
        app.launch()
        
        let avatar = app.images["profile.avatar"]
        let name = app.staticTexts["profile.name"]
        let email = app.staticTexts["profile.email"]
        let table = app.tables["profile.table"]
        let logout = app.buttons["profile.logout"]
        let delete = app.buttons["profile.deleteAccount"]
        
        XCTAssertTrue(avatar.waitForExistence(timeout: 2))
        XCTAssertTrue(name.waitForExistence(timeout: 2))
        XCTAssertTrue(email.waitForExistence(timeout: 2))
        XCTAssertTrue(table.waitForExistence(timeout: 2))
        XCTAssertTrue(logout.waitForExistence(timeout: 2))
        XCTAssertTrue(delete.waitForExistence(timeout: 2))
        
        let editProfileCell = table.cells.staticTexts["Редактировать профиль"]
        let ordersCell = table.cells.staticTexts["Мои заказы"]
        XCTAssertTrue(editProfileCell.exists)
        XCTAssertTrue(ordersCell.exists)
        
        editProfileCell.tap()
        ordersCell.tap()
        
        logout.tap()
        delete.tap()
    }
}
