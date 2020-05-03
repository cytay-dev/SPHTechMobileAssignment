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
    
    ///Test if data is not nil if success is false
    func testGetDataOnSuccessStateIsFalse() throws {
        let mockServiceApiClient = MobileDataAPIClient.mock()
        let originalURL = URL(string: MobileDataAPIClient.MOBILE_DATA_API_URL)!
        
        let exp = expectation(description: "expecting to get success = false in response")

        let mock = Mock(url: originalURL, ignoreQuery: true, dataType: .json, statusCode: 200, data: [.get : MockedData.successWithFailureState.data])
        mock.register()
        
        mockServiceApiClient.requestDataUsage(numberOfItems: 5, offset: 0, completion: {}, success: { (response) in
            XCTAssertNotNil(response.success)
            XCTAssertFalse(response.success!)
            exp.fulfill()
        }, fail: { (err) in
            XCTFail("Should not fail")
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
    
    ///Test if able to notice last set of data is having a decrease in volume and first set is not having a decrease
    func testDetectDecreaseIsWorking() throws{
        let exp = expectation(description: "expecting to be able to detect decrease")

        let mockServiceApiClient = MobileDataAPIClient.mock()
        let originalURL = URL(string: MobileDataAPIClient.MOBILE_DATA_API_URL)!
        let mock = Mock(url: originalURL, ignoreQuery: true, dataType: .json, statusCode: 200, data: [.get : MockedData.successWithDataHasDecrease.data])
        mock.register()
        mockServiceApiClient.requestDataUsage(numberOfItems: 5, offset: 0, completion: {}, success: { (response) in
            if let result = response.result, let records = result.records{
                let mobileUsageData = MobileUsageData(records, fmt: .Year)
                //Have decrease
                let lastRecord = mobileUsageData.get(mobileUsageData.count - 1)
                XCTAssertNotNil(lastRecord.data)
                XCTAssertTrue(lastRecord.data!.hasDecreaseInQuater)
                
                //No decrease
                let firstRecord = mobileUsageData.get(0)
                XCTAssertNotNil(firstRecord.data)
                XCTAssertFalse(firstRecord.data!.hasDecreaseInQuater)
            }
            else{
               XCTFail("Should not fail")
            }
            exp.fulfill()
            
        }, fail: { (err) in
            XCTFail("Should not fail")
            exp.fulfill()
        })
        
        waitForExpectations(timeout: 10.0, handler: nil)
    }
    
    ///Test MobileUsageData is not throwing exception when access out of bound index
    func testListWhenAccessedOutOfBoundIndex() throws{
        let exp = expectation(description: "expecting out of bound index access not to fail")

        let mockServiceApiClient = MobileDataAPIClient.mock()
        let originalURL = URL(string: MobileDataAPIClient.MOBILE_DATA_API_URL)!
        let mock = Mock(url: originalURL, ignoreQuery: true, dataType: .json, statusCode: 200, data: [.get : MockedData.successWithDataHasDecrease.data])
        mock.register()
        mockServiceApiClient.requestDataUsage(numberOfItems: 5, offset: 0, completion: {}, success: { (response) in
            if let result = response.result, let records = result.records{
                let mobileUsageData = MobileUsageData(records, fmt: .Year)
                let index = mobileUsageData.count
                XCTAssertNotNil(mobileUsageData.get(index + 1))
                XCTAssertNil(mobileUsageData.get(index + 1).data)
            }
            else{
               XCTFail("Should not fail")
            }
            exp.fulfill()
            
        }, fail: { (err) in
            XCTFail("Should not fail")
            exp.fulfill()
        })
        
        waitForExpectations(timeout: 10.0, handler: nil)
    }
    
    ///Test MobileUsageData filtering logic is working and proper data is returned for use
    func testFilteredRangeListIsCorrect() throws{
        let exp = expectation(description: "expecting filter to work")

        let mockServiceApiClient = MobileDataAPIClient.mock()
        let originalURL = URL(string: MobileDataAPIClient.MOBILE_DATA_API_URL)!
        let mock = Mock(url: originalURL, ignoreQuery: true, dataType: .json, statusCode: 200, data: [.get : MockedData.successWithDataHasDecrease.data])
        mock.register()
        mockServiceApiClient.requestDataUsage(numberOfItems: 5, offset: 0, completion: {}, success: { (response) in
            if let result = response.result, let records = result.records{
                let mobileUsageData = MobileUsageData(records, fmt: .Year)
                mobileUsageData.setFilter(minYear: 2016, maxYear: 2018)
                XCTAssertEqual(mobileUsageData.count, 1)
            }
            else{
               XCTFail("Should not fail")
            }
            exp.fulfill()
            
        }, fail: { (err) in
            XCTFail("Should not fail")
            exp.fulfill()
        })
        
        waitForExpectations(timeout: 10.0, handler: nil)
    }
    
    ///Test if save and get offline content function is working
    func testAbleToSaveAndGetOfflineContent() throws{
        let exp = expectation(description: "expecting to be able to save for offline content access")

        let mockServiceApiClient = MobileDataAPIClient.mock()
        let originalURL = URL(string: MobileDataAPIClient.MOBILE_DATA_API_URL)!
        let mock = Mock(url: originalURL, ignoreQuery: true, dataType: .json, statusCode: 200, data: [.get : MockedData.successWithData.data])
        mock.register()
        mockServiceApiClient.requestDataUsage(numberOfItems: 5, offset: 0, completion: {}, success: { (response) in
            let result = self.trySaveAndGetJSON(response: response)
            XCTAssertTrue(result)
            exp.fulfill()
            
        }, fail: { (err) in
            XCTFail("Should not fail")
            exp.fulfill()
        })
        
        waitForExpectations(timeout: 10.0, handler: nil)
        
    }
    
    /**
     Function to use to simulate similar usage in ViewController call for test case `testAbleToSaveAndGetOfflineContent()`
        - Parameters:
            - response: Data returned from network request
        - Returns:
                Boolean state true if inputs is able to be save and read out properly else false
     */
    private func trySaveAndGetJSON(response: MobileDataUsageResponse) -> Bool{
        do{
            try OfflineCacheManager.mock().saveJSON(array: response)
            let result = try OfflineCacheManager.mock().readJSON(MobileDataUsageResponse.self)
            return result != nil
        }
        catch{
            return false
        }
    }

}
