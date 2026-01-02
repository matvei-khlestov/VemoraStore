//
//  SignUpUITests.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 16.10.2025.
//

import XCTest

final class SignUpUITests: XCTestCase {

    @MainActor
    func test_submit_disabled_until_valid_input_and_agree() {
        let app = UITestUtils.makeApp(startScreen: "signup")
        app.launch()

        let name   = app.textFields["signup.name"]
        let email  = app.textFields["signup.email"]
        let pass   = app.secureTextFields["signup.password"]
        let agree  = app.buttons["signup.agree.checkbox"]
        let submit = app.buttons["signup.submit"]

        XCTAssertTrue(name.waitForExistence(timeout: 2))
        XCTAssertTrue(email.waitForExistence(timeout: 2))
        XCTAssertTrue(pass.waitForExistence(timeout: 2))
        XCTAssertTrue(agree.waitForExistence(timeout: 2))
        XCTAssertTrue(submit.waitForExistence(timeout: 2))

        XCTAssertFalse(submit.isEnabled)

        UITestUtils.clearAndType(name,  "John Doe")
        UITestUtils.clearAndType(email, "john@example.com")
        UITestUtils.clearAndType(pass,  "StrongP@ssw0rd")

        XCTAssertFalse(submit.isEnabled)
        
        agree.tap()
        UITestUtils.waitEnabled(submit, in: self)
        XCTAssertTrue(submit.isEnabled)
    }
}
