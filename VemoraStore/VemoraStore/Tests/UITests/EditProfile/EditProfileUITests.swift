//
//  EditProfileUITests.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 16.10.2025.
//

import XCTest

final class EditProfileUITests: XCTestCase {

    @MainActor
    func test_elements_exist() {
        let app = UITestUtils.makeApp(startScreen: "editProfile")
        app.launch()

        let navTitle = app.navigationBars.staticTexts["Редактирование профиля"]
        XCTAssertTrue(navTitle.waitForExistence(timeout: 2), "navigation title not found")

        let changePhoto = app.buttons["Изменить фото"]
        XCTAssertTrue(changePhoto.waitForExistence(timeout: 2), "change photo button not found")

        let table = app.tables.firstMatch
        XCTAssertTrue(table.waitForExistence(timeout: 2), "table not found")
        XCTAssertGreaterThanOrEqual(table.cells.count, 3, "expected at least 3 rows in edit profile table")
    }

    @MainActor
    func test_rows_are_tappable() {
        let app = UITestUtils.makeApp(startScreen: "editProfile")
        app.launch()

        let table = app.tables.firstMatch
        XCTAssertTrue(table.waitForExistence(timeout: 2))

        let first = table.cells.element(boundBy: 0)
        let second = table.cells.element(boundBy: 1)
        let third = table.cells.element(boundBy: 2)

        XCTAssertTrue(first.waitForExistence(timeout: 2))
        XCTAssertTrue(second.waitForExistence(timeout: 2))
        XCTAssertTrue(third.waitForExistence(timeout: 2))

        first.tap()
        second.tap()
        third.tap()

        XCTAssertTrue(table.exists)
    }

    @MainActor
    func test_change_photo_button_is_tappable() {
        let app = UITestUtils.makeApp(startScreen: "editProfile")
        app.launch()

        let changePhoto = app.buttons["Изменить фото"]
        XCTAssertTrue(changePhoto.waitForExistence(timeout: 2))

        changePhoto.tap()

        XCTAssertTrue(changePhoto.exists)
    }
}
