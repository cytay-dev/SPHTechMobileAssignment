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

    func testNavigable() throws{
      //  let app = XCUIApplication()
      //  app.launch()
        
    }
    func testDataShowing() throws{
        let app = XCUIApplication()
        app.launchArguments += ["UI-TESTING"]
        app.launchEnvironment["MockData"] = MockedData.response.string
        app.launch()
        
        let tablesQuery = app.tables
        let count = tablesQuery.cells.count
        XCTAssertEqual(count, 3)
    }
    func testNoDataMessage() throws{
        let app = XCUIApplication()
        app.launchArguments += ["UI-TESTING"]
        app.launchEnvironment["MockData"] = MockedData.responseEmpty.string
        app.launch()
       
        let lbl = app.staticTexts["No Mobile Usage data is available"]
        XCTAssertNotNil(lbl)
        XCTAssertEqual("No Mobile Usage data is available", lbl.label)
    }
    
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
    
    func testTimeOutErrorMessage() throws{
        let app = XCUIApplication()
        app.launchArguments += ["UI-TESTING"]
        app.launchEnvironment["MockData"] = MockedData.response.string
        app.launchEnvironment["FailureCase"] = "timeout"
        app.launch()
       
        let lbl = app.staticTexts["Request has timed out. Please try again"]
        XCTAssertTrue(lbl.waitForExistence(timeout: 400))
    }
    
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
    
    func testExample() throws {
        // UI tests must launch the application that they test.
                        let app = XCUIApplication()
        
   //     app.launchArguments += ["UI-TESTING"]
    //            app.launchEnvironment["MockData"] = MockedData.response.string
        
    //    let app = XCUIApplication()
    //    app.staticTexts["No Mobile Usage data is available"].tap()
    //    app/*@START_MENU_TOKEN@*/.staticTexts["Click to refresh"]/*[[".buttons[\"Click to refresh\"].staticTexts[\"Click to refresh\"]",".staticTexts[\"Click to refresh\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
                          app.launch()
    /*    let app = XCUIApplication()
        app.navigationBars["2013"].buttons["Mobile Data Usage List"].tap()
        
        let tablesQuery = app.tables
        tablesQuery/*@START_MENU_TOKEN@*/.staticTexts["11.453192000000001"]/*[[".cells.staticTexts[\"11.453192000000001\"]",".staticTexts[\"11.453192000000001\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        tablesQuery/*@START_MENU_TOKEN@*/.cells.containing(.staticText, identifier:"2011")/*[[".cells.containing(.staticText, identifier:\"14.638703\")",".cells.containing(.staticText, identifier:\"2011\")"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.images["warning"].tap()
        
        let navigationBar = app.navigationBars["2011"]
        navigationBar.staticTexts["2011"].tap()
        navigationBar.buttons["Mobile Data Usage List"].tap()
        
        
        let app = XCUIApplication()
        let tablesQuery = app.tables
        let staticText = tablesQuery/*@START_MENU_TOKEN@*/.staticTexts["11.453192000000001"]/*[[".cells.staticTexts[\"11.453192000000001\"]",".staticTexts[\"11.453192000000001\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        staticText.tap()
        staticText.tap()
        tablesQuery/*@START_MENU_TOKEN@*/.cells.containing(.staticText, identifier:"2011")/*[[".cells.containing(.staticText, identifier:\"14.638703\")",".cells.containing(.staticText, identifier:\"2011\")"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.images["warning"].tap()
        app.navigationBars["2011"].buttons["Mobile Data Usage List"].tap()
        tablesQuery/*@START_MENU_TOKEN@*/.cells.containing(.staticText, identifier:"2013")/*[[".cells.containing(.staticText, identifier:\"28.496851999999997\")",".cells.containing(.staticText, identifier:\"2013\")"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.images["warning"].tap()
        let app = XCUIApplication()
        let tablesQuery = app.tables
        tablesQuery/*@START_MENU_TOKEN@*/.cells.containing(.staticText, identifier:"2011")/*[[".cells.containing(.staticText, identifier:\"14.638703\")",".cells.containing(.staticText, identifier:\"2011\")"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.images["warning"].tap()
        app.navigationBars["2011"].buttons["Mobile Data Usage List"].tap()
        tablesQuery/*@START_MENU_TOKEN@*/.staticTexts["6.228985000000001"]/*[[".cells.staticTexts[\"6.228985000000001\"]",".staticTexts[\"6.228985000000001\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        tablesQuery/*@START_MENU_TOKEN@*/.staticTexts["1.543719"]/*[[".cells.staticTexts[\"1.543719\"]",".staticTexts[\"1.543719\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.swipeDown()
        XCUIApplication().tables/*@START_MENU_TOKEN@*/.staticTexts["6.228985000000001"]/*[[".cells.staticTexts[\"6.228985000000001\"]",".staticTexts[\"6.228985000000001\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()*/
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

}
