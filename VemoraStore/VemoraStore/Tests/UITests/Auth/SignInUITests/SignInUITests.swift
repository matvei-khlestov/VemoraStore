//
//  SignInUITests.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 16.10.2025.
//

import XCTest

final class SignInUITests: XCTestCase {
    
    @MainActor
    func test_submit_disabled_until_valid_input() {
        let app = UITestUtils.makeApp(startScreen: "signin")
        app.launch()
        
        let email = app.textFields["signin.email"]
        let pass = app.secureTextFields["signin.password"]
        let submit = app.buttons["signin.submit"]
        
        XCTAssertTrue(email.waitForExistence(timeout: 2))
        XCTAssertTrue(pass.waitForExistence(timeout: 2))
        XCTAssertTrue(submit.waitForExistence(timeout: 2))
        
        XCTAssertFalse(submit.isEnabled)
        
        UITestUtils.clearAndType(email, "user@example.com")
        UITestUtils.clearAndType(pass, "StrongP@ss123")
        
        UITestUtils.waitEnabled(submit, in: self)
        XCTAssertTrue(submit.isEnabled)
    }
}
