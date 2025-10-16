//
//  BaseEditFieldUITests.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 16.10.2025.
//

import XCTest

final class BaseEditFieldUITests: XCTestCase {
    
    private struct Case {
        let start: String
        let prefix: String
        let value: String
    }
    
    private let cases: [Case] = [
        .init(
            start: "editName",
            prefix: "edit.name",
            value: "John Snow"
        ),
        .init(
            start: "editEmail",
            prefix: "edit.email",
            value: "john@example.com"
        ),
        .init(
            start: "editPhone",
            prefix: "edit.phone",
            value: "+79990001122"
        )
    ]
    
    @MainActor
    func test_elements_exist_and_initial_state() {
        for c in cases {
            let app = UITestUtils.makeApp(startScreen: c.start)
            app.launch()
            
            let field  = app.textFields["\(c.prefix).field"]
            let submit = app.buttons["\(c.prefix).submit"]
            
            XCTAssertTrue(field.waitForExistence(timeout: 2),  "Field not found for \(c.start)")
            XCTAssertTrue(submit.waitForExistence(timeout: 2), "Submit not found for \(c.start)")
            XCTAssertFalse(submit.isEnabled, "Submit should be disabled initially for \(c.start)")
        }
    }
    
    @MainActor
    func test_submit_enables_on_valid_input_for_all_edit_screens() {
        for c in cases {
            let app = UITestUtils.makeApp(startScreen: c.start)
            app.launch()
            
            let field  = app.textFields["\(c.prefix).field"]
            let submit = app.buttons["\(c.prefix).submit"]
            
            XCTAssertTrue(field.waitForExistence(timeout: 2),  "Field not found for \(c.start)")
            XCTAssertTrue(submit.waitForExistence(timeout: 2), "Submit not found for \(c.start)")
            XCTAssertFalse(submit.isEnabled, "Submit should be disabled initially for \(c.start)")
            
            UITestUtils.clearAndType(field, c.value)
            
            UITestUtils.waitEnabled(submit, in: self)
            XCTAssertTrue(submit.isEnabled, "Submit should become enabled after valid input for \(c.start)")
        }
    }
}
