//
//  UITestUtils.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 16.10.2025.
//

import XCTest

enum UITestUtils {
    
    static func makeApp(startScreen: String? = nil) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments += ["-uiTests", "1"]
        app.launchEnvironment["API_STUB_MODE"] = "1"
        
        if let screen = startScreen {
            app.launchEnvironment["START_SCREEN"] = screen
            
            switch screen {
            case "profile", "editProfile", "editName", "editEmail", "editPhone":
                app.launchEnvironment["TEST_UID"] = "ui-tests-user"
            default:
                break
            }
        }
        
        return app
    }
    
    static func waitEnabled(
        _ element: XCUIElement,
        in testCase: XCTestCase,
        timeout: TimeInterval = 2
    ) {
        let predicate = NSPredicate(format: "isEnabled == true")
        let expectation = testCase.expectation(for: predicate, evaluatedWith: element)
        testCase.wait(for: [expectation], timeout: timeout)
    }
    
    static func clearAndType(_ element: XCUIElement, _ text: String) {
        element.tap()
        if let s = element.value as? String, !s.isEmpty {
            let deletes = String(
                repeating: XCUIKeyboardKey.delete.rawValue,
                count: s.count
            )
            element.typeText(deletes)
        }
        element.typeText(text)
    }
}
