//
//  MockNetworkManager.swift
//  com.dev.mobileStats
//
//  Created by Tay Chee Yang on 2/5/20.
//  Copyright © 2020 cytay. All rights reserved.
//

import Foundation
import Alamofire
import Mocker

/**
Mock Network request handler that fake service request to API servers and return dummy data
*/
class MockRequestHandler: RequestHandler{
    // MARK: - Variables
    ///Mock service session manager using `Mocker` framework
    private lazy var sessionManager: Session = {
      let configuration = URLSessionConfiguration.af.default
      configuration.protocolClasses = [MockingURLProtocol.self] + (configuration.protocolClasses ?? [])
      let sessionManager = Session(configuration: configuration)
        return sessionManager
    }()
    
    // MARK: - Initialization
    init(){
        //Setup mock if is for UI Testing
        #if DEBUG
        if ProcessInfo.processInfo.arguments.contains("UI-TESTING") {
            if let jsonString = ProcessInfo.processInfo.environment["MockData"], let data = jsonString.data(using: .utf8) {
                let originalURL = URL(string: MobileDataAPIClient.MOBILE_DATA_API_URL)!
                var forTimeOut = false
                var statusCode = 200
                if let state = ProcessInfo.processInfo.environment["FailureCase"]{
                    switch state{
                    case "timeout":
                        forTimeOut = true
                    case "internalerror":
                        statusCode = 500
                    case "404":
                        statusCode = 404
                    default:
                        statusCode = 200
                    }
                }
                
                var mock = Mock(url: originalURL, ignoreQuery: true, dataType: .json, statusCode: statusCode, data: [.get : data]) //As it was parse using utf16 in UI Test
                if forTimeOut{
                    mock.delay = DispatchTimeInterval.seconds(300) //5mins
                }
                mock.register()
            }
        }
        #endif
    }
    
    // MARK: - Functions
    /**
    Make request ot API server using given url and parameters
    - Parameters:
       -   url: Url of the service
       - parameter: Parameters to be included in the query string of the url
    */
    func request(url: String, parameter: Parameters) -> DataRequest {
        return sessionManager.request(url,parameters: parameter)
    }
    
    
}
