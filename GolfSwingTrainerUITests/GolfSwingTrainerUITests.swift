//
//  GolfSwingTrainerUITests.swift
//  GolfSwingTrainerUITests
//
//  Created by Harry Liu on 2024-09-10.
//

import XCTest
@testable import GolfSwingTrainer

final class GolfSwingTrainerUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()

        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}

final class SwingDataCalculationUtilities: XCTestCase {
    func testCalculateAngleValidData() {
        let data: [[String: Double]] = [
            ["x": 1.0, "y": 2.0, "z": 2.0],
            ["x": 0.0, "y": 3.0, "z": 4.0]
        ]
        let angle = SwingMathUtilities.calculateAngle(from: data)
        XCTAssertNotNil(angle)
        XCTAssertEqual(round(angle!), 53)
    }
    
    func testCalculateAngleEmptyData() {
        let data: [[String: Double]] = []
        let angle = SwingMathUtilities.calculateAngle(from: data)
        XCTAssertNil(angle)
    }
    
    func testCalculateAngleInvalidData() {
        let data: [[String: Double]] = [
            ["x": 1.0], // Missing "y" and "z"
            ["y": 2.0, "z": 3.0] // Missing "x"
        ]
        let angle = SwingMathUtilities.calculateAngle(from: data)
        XCTAssertNil(angle)
    }
    
    func testCalculateVelocityValidData() {
        let accelerationData: [[String: Double]] = [
            ["x": 1.0, "y": 0.0, "z": 0.0],
            ["x": 0.5, "y": 0.5, "z": 0.0]
        ]
        let velocity = SwingMathUtilities.calculateVelocity(from: accelerationData)
        XCTAssertNotNil(velocity)
        XCTAssertEqual(round(velocity!), 0) // Velocity ~0 (approximation for small data)
    }
    
    func testCalculateVelocityEmptyData() {
        let accelerationData: [[String: Double]] = []
        let velocity = SwingMathUtilities.calculateVelocity(from: accelerationData)
        XCTAssertNil(velocity)
    }
    
    func testRadToDeg() {
        let radians: Double = .pi // 180 degrees
        let degrees = SwingMathUtilities.radTodeg(radians)
        XCTAssertEqual(degrees, 180.0)
    }
}
