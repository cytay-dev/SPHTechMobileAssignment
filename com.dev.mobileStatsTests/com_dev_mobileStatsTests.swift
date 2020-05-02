//
//  com_dev_mobileStatsTests.swift
//  com.dev.mobileStatsTests
//
//  Created by Tay Chee Yang on 30/4/20.
//  Copyright © 2020 cytay. All rights reserved.
//

import XCTest
import Mocker

@testable import com_dev_mobileStats

class com_dev_mobileStatsTests: XCTestCase {
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    ///Test if data is correct when there is data
    func testGetDataOnSuccess() throws {
        let mockServiceApiClient = MobileDataAPIClient.mock()
        let originalURL = URL(string: MobileDataAPIClient.MOBILE_DATA_API_URL)!
        
        let exp = expectation(description: "expecting to get success response")

        let mock = Mock(url: originalURL, ignoreQuery: true, dataType: .json, statusCode: 200, data: [.get : MockedData.successWithData.data])
        mock.register()
        
        mockServiceApiClient.requestDataUsage(numberOfItems: 5, offset: 0, completion: {}, success: { (response) in
            XCTAssertEqual(response.result?.records?.count, 5)
            exp.fulfill()
        }, fail: { (err) in
            XCTFail("Should not fail on success")
            exp.fulfill()
        })
        
        waitForExpectations(timeout: 10.0, handler: nil)
    }

    ///Test if there is error when http status 500 is returned
    func testWhenHitInternalServerError() throws {
        let mockServiceApiClient = MobileDataAPIClient.mock()
        let originalURL = URL(string: MobileDataAPIClient.MOBILE_DATA_API_URL)!
        
        let exp = expectation(description: "expecting to get failure response")

        let mock = Mock(url: originalURL, ignoreQuery: true, dataType: .json, statusCode: 500, data: [.get : Data()])
        mock.register()
        
        mockServiceApiClient.requestDataUsage(numberOfItems: 5, offset: 0, completion: {}, success: { (response) in
            XCTFail("Should not fail on success")
            exp.fulfill()
        }, fail: { (err) in
            XCTAssertNotNil(err)
            exp.fulfill()
        })
        
        waitForExpectations(timeout: 10.0, handler: nil)
    }
    
    ///Test if there is correct timeout error when timeout occured
    func testWhenTimeout() throws {
        let mockServiceApiClient = MobileDataAPIClient.mock()
        let originalURL = URL(string: MobileDataAPIClient.MOBILE_DATA_API_URL)!
        
        let exp = expectation(description: "expecting to get timed out response")
        
        var mock = Mock(url: originalURL, ignoreQuery: true, dataType: .json, statusCode: 200, data: [.get : MockedData.successWithData.data])
        mock.delay = DispatchTimeInterval.seconds(300) //5mins
        mock.register()
        
        mockServiceApiClient.requestDataUsage(numberOfItems: 5, offset: 0, completion: {}, success: { (response) in
            XCTFail("Should not fail on success")
            exp.fulfill()
        }, fail: { (err) in
            if let afError = err.asAFError {
                switch afError {
                case .sessionTaskFailed(let sessionError):
                    if let urlError = sessionError as? URLError {
                            XCTAssertEqual(urlError.code, URLError.timedOut)
                        }
                    else{
                        XCTFail("Not the expected error")
                    }
                default:
                    XCTFail("Not the expected error")
                }
                
            }
            else {
               XCTFail("Not the expected error")
            }
            exp.fulfill()
        })
        
        waitForExpectations(timeout: 400.0, handler: nil)
    }
    
    ///Test if there is no data when no data is returned
    func testWhenSuccessButNoData() throws {
        let mockServiceApiClient = MobileDataAPIClient.mock()
        let originalURL = URL(string: MobileDataAPIClient.MOBILE_DATA_API_URL)!
        
        let exp = expectation(description: "expecting to get timed out response")
       
        let mock = Mock(url: originalURL, ignoreQuery: true, dataType: .json, statusCode: 200, data: [.get : MockedData.successWithNoData.data])
        mock.register()
        
        mockServiceApiClient.requestDataUsage(numberOfItems: 5, offset: 0, completion: {}, success: { (response) in
            XCTAssertEqual(response.result?.records?.count, 0)
            exp.fulfill()
        }, fail: { (err) in
            XCTFail("Not supposed to fail")
            exp.fulfill()
        })
        
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    ///Test if there is error when http status 404 is returned
    func testWhenHit404Error() throws {
        let mockServiceApiClient = MobileDataAPIClient.mock()
        let originalURL = URL(string: MobileDataAPIClient.MOBILE_DATA_API_URL)!
        
        let exp = expectation(description: "expecting to get failure response")

        let mock = Mock(url: originalURL, ignoreQuery: true, dataType: .json, statusCode: 404, data: [.get : Data()])
        mock.register()
        
        mockServiceApiClient.requestDataUsage(numberOfItems: 5, offset: 0, completion: {}, success: { (response) in
            XCTFail("Should not fail on success")
            exp.fulfill()
        }, fail: { (err) in
            XCTAssertNotNil(err)
            exp.fulfill()
        })
        
        waitForExpectations(timeout: 10.0, handler: nil)
    }

}
