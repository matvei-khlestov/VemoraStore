//
//  Combine+XCTest.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 15.10.2025.
//

import XCTest
import Combine

enum CombineAwaitError: Error { case noValue }

@discardableResult
func awaitValue<P: Publisher>(
    _ publisher: P,
    dropFirst count: Int = 0,
    after action: @escaping () -> Void = {},
    timeout: TimeInterval = 2,
    file: StaticString = #file, line: UInt = #line
) throws -> P.Output where P.Failure == Never {
    let exp = XCTestExpectation(description: "awaitValue")
    var output: P.Output?
    var cancellable: AnyCancellable?
    
    cancellable = publisher
        .dropFirst(count)
        .first()
        .sink { value in
            output = value
            exp.fulfill()
        }
    
    if Thread.isMainThread {
        action()
    } else {
        DispatchQueue.main.sync { action() }
    }
    
    let result = XCTWaiter.wait(for: [exp], timeout: timeout)
    defer { cancellable?.cancel() }
    
    guard result == .completed, let value = output else {
        XCTFail("No value received", file: file, line: line)
        throw CombineAwaitError.noValue
    }
    return value
}

@discardableResult
func awaitValue<P: Publisher>(
    _ publisher: P,
    where predicate: @escaping (P.Output) -> Bool,
    after action: @escaping () -> Void = {},
    timeout: TimeInterval = 2,
    file: StaticString = #file, line: UInt = #line
) throws -> P.Output where P.Failure == Never {
    let exp = XCTestExpectation(description: "awaitValue(where:)")
    var output: P.Output?
    var cancellable: AnyCancellable?
    
    cancellable = publisher
        .filter(predicate)
        .first()
        .sink { value in
            output = value
            exp.fulfill()
        }
    
    if Thread.isMainThread {
        action()
    } else {
        DispatchQueue.main.sync { action() }
    }
    
    let result = XCTWaiter.wait(for: [exp], timeout: timeout)
    defer { cancellable?.cancel() }
    
    guard result == .completed, let value = output else {
        XCTFail("No value received", file: file, line: line)
        throw CombineAwaitError.noValue
    }
    return value
}
