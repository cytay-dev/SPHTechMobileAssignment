//
//  com_dev_mobileStatsUITests.swift
//  com.dev.mobileStatsUITests
//
//  Created by Tay Chee Yang on 2/5/20.
//  Copyright © 2020 cytay. All rights reserved.
//

import XCTest

class com_dev_mobileStatsUITests: XCTestCase {

    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        
        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    ///Test if table is correct when populated with data
    func testDataShowing() throws{
        let app = XCUIApplication()
        app.launchArguments += ["UI-TESTING"]
        app.launchEnvironment["MockData"] = MockedData.response.string
        app.launch()
        
        let tablesQuery = app.tables
        let count = tablesQuery.cells.count
        XCTAssertEqual(count, 3)
    }
    
    ///Test if table is empty when there is no data
    func testNoDataMessage() throws{
        let app = XCUIApplication()
        app.launchArguments += ["UI-TESTING"]
        app.launchEnvironment["MockData"] = MockedData.responseEmpty.string
        app.launch()
       
        let lbl = app.staticTexts["No Mobile Usage data is available"]
        XCTAssertNotNil(lbl)
        XCTAssertEqual("No Mobile Usage data is available", lbl.label)
    }
    
    ///Test if table is empty when there is no data
    func testWhenSuccessIsFalseMessage() throws{
        let app = XCUIApplication()
        app.launchArguments += ["UI-TESTING"]
        app.launchEnvironment["MockData"] = MockedData.successWithFailureState.string
        app.launch()
       
        let lbl = app.staticTexts["Error retrieving data from Data.gov.sg"]
        XCTAssertNotNil(lbl)
        XCTAssertEqual("Error retrieving data from Data.gov.sg", lbl.label)
    }
    
    ///Test if is there is no image when the row with data that has no decrease in volume in its quarters
    func testRowWithoutDecreaseHasNoImage() throws{
        let app = XCUIApplication()
        app.launchArguments += ["UI-TESTING"]
        app.launchEnvironment["MockData"] = MockedData.response.string
        app.launch()
        
        let tablesQuery = app.tables
        let firstRow = tablesQuery.firstMatch.cells.element(boundBy: 0)
        XCTAssertNotNil(firstRow)
        XCTAssertFalse(firstRow.images["warning"].exists)
    }
    ///Test if there is image when there is a row with data that has decrease in volume in its quarters
    func testLastRowHasDecreaseInVolume() throws{
        let app = XCUIApplication()
        app.launchArguments += ["UI-TESTING"]
        app.launchEnvironment["MockData"] = MockedData.response.string
        app.launch()
        
        let tablesQuery = app.tables
        let lastRow = tablesQuery.firstMatch.cells.element(boundBy: tablesQuery.cells.count - 1)
        XCTAssertNotNil(lastRow)
        XCTAssertNotNil(lastRow.images["warning"])
        XCTAssertTrue(lastRow.images["warning"].exists)
    }
    
    ///Test if it can be navigated when there is a row with data that has decrease in volume in its quarters
    func testRowWithDecreaseCanBeNavigated() throws{
        func testLastRowHasDecreaseInVolume() throws{
            let app = XCUIApplication()
            app.launchArguments += ["UI-TESTING"]
            app.launchEnvironment["MockData"] = MockedData.response.string
            app.launch()
            
            let tablesQuery = app.tables
            let lastRow = tablesQuery.firstMatch.cells.element(boundBy: tablesQuery.cells.count - 1)
            XCTAssertNotNil(lastRow)
            XCTAssertNotNil(lastRow.images["warning"])
            XCTAssertTrue(lastRow.images["warning"].exists)
            XCTAssertTrue(lastRow.images["warning"].isHittable)
        }
    }
    
    ///Test if is navigated when there is a row with data that has decrease in volume in its quarters
    func testNavigateRowWithDecreaseInVolume() throws{
        let app = XCUIApplication()
        app.launchArguments += ["UI-TESTING"]
        app.launchEnvironment["MockData"] = MockedData.response.string
        app.launch()
        
        let tablesQuery = app.tables
        let lastRow = tablesQuery.firstMatch.cells.element(boundBy: tablesQuery.cells.count - 1)
        lastRow.images["warning"].tap()
        let navigationBar = app.navigationBars["2016"]
        XCTAssertNotNil(navigationBar)

    }
    
    ///Test where there is no internet
    func testWhenThereIsNoInternet() throws{
        let app = XCUIApplication()
        app.launchArguments += ["UI-TESTING"]
        app.launchEnvironment["MockData"] = MockedData.response.string
        app.launchEnvironment["MockInternetState"] = "N"
        app.launch()
       
        let lbl = app.staticTexts["Using offline content"]
        XCTAssertNotNil(lbl)
        XCTAssertEqual("Using offline content", lbl.label)
    }
    
    ///Test when 500 status is returned from network call
    func testInternalErrorMessage() throws{
        let app = XCUIApplication()
        app.launchArguments += ["UI-TESTING"]
        app.launchEnvironment["MockData"] = MockedData.response.string
        app.launchEnvironment["FailureCase"] = "internalerror"
        app.launch()
       
        let lbl = app.staticTexts["Something went wrong. Please try again."]
        XCTAssertNotNil(lbl)
        XCTAssertEqual("Something went wrong. Please try again.", lbl.label)
    }
    
    ///Test when timeout is returned from network call
    func testTimeOutErrorMessage() throws{
        let app = XCUIApplication()
        app.launchArguments += ["UI-TESTING"]
        app.launchEnvironment["MockData"] = MockedData.response.string
        app.launchEnvironment["FailureCase"] = "timeout"
        app.launch()
       
        let lbl = app.staticTexts["Request has timed out. Please try again"]
        XCTAssertTrue(lbl.waitForExistence(timeout: 400))
    }
    
    ///Test when 404 status is returned from network call
    func test404ErrorMessage() throws{
        let app = XCUIApplication()
        app.launchArguments += ["UI-TESTING"]
        app.launchEnvironment["MockData"] = MockedData.response.string
        app.launchEnvironment["FailureCase"] = "404"
        app.launch()
       
        let lbl = app.staticTexts["Something went wrong. Please try again."]
        XCTAssertNotNil(lbl)
        XCTAssertEqual("Something went wrong. Please try again.", lbl.label)
    }
    
    ///Test when 404 status is returned from network call and refresh button is available and clickable
    func testRefreshButtonWhenErrorOccur() throws{
        let app = XCUIApplication()
        app.launchArguments += ["UI-TESTING"]
        app.launchEnvironment["MockData"] = MockedData.response.string
        app.launchEnvironment["FailureCase"] = "404"
        app.launch()
        
        let btn = app.buttons["Click to refresh"]
        XCTAssertNotNil(btn)
        XCTAssertTrue(btn.exists)
        XCTAssertTrue(btn.isHittable)
    }

}
