//
//  MobileDataAPIClient.swift
//  com.dev.mobileStats
//
//  Created by Tay Chee Yang on 2/5/20.
//  Copyright © 2020 cytay. All rights reserved.
//

import Foundation
import Alamofire
/**
 API Client class to access Data.gov.sg to get mobile data usage information
 */
class MobileDataAPIClient : APIClient{
    
    ///Request structure to send to Data.gov.sg for request
    struct MobileDataRequest : Encodable{
        let resourceId : String
        let limit : Int
        let offset: Int
        var parametersRepresentation: [String: Any] {
            return [
                "resource_id" : resourceId,
                "limit" : limit,
                "offset" : offset
            ]
        }
    }
    // MARK: - Variables
    private let RESOURCE_ID = "a807b7ab-6cad-4aa6-87d0-e283a7353a0f"
    public static let MOBILE_DATA_API_URL = "https://data.gov.sg/api/action/datastore_search"
    private let mobileApiUrl = MobileDataAPIClient.MOBILE_DATA_API_URL
    private var requestHandler: RequestHandler
    
    private static var sharedAPIClient: MobileDataAPIClient = {
        if ProcessInfo.processInfo.arguments.contains("UI-TESTING") {
            return MobileDataAPIClient(environment: .mock)
        }
        else{
            return MobileDataAPIClient(environment: .production)
        }
    }()
    
    private static var productionAPIClient: MobileDataAPIClient = {
        let mgr = MobileDataAPIClient(environment: .production)
        //Do configuration next time
        return mgr
    }()
    
    private static var mockAPIClient: MobileDataAPIClient = {
        let mgr = MobileDataAPIClient(environment: .mock)
        //Do configuration next time
        return mgr
    }()
    
    // MARK: - Functions
    /**
     Instance for accessing api client.
     - Important: Supported for use in **debug**, **release** and **UI Testing** build
     */
    class func shared() -> MobileDataAPIClient {
        return sharedAPIClient
    }
    
    /**
    Instance for accessing api client.
    - Important: Supported for use in **release** build only
    */
    class func production() -> MobileDataAPIClient {
        return productionAPIClient
    }
    
    /**
    Mock instance for accessing api client.
    - Important: Supported for use in **debug** and **UI Testing** build only
    */
    class func mock() -> MobileDataAPIClient {
        return mockAPIClient
    }
    
    // MARK: - Initialization
    /**
        Initialize `MobileDataAPIClient` for use.
        - Parameters:
            - environment: The environment the api cilent is to be initialized for
     */
    init(environment: APIEnvironment){
        switch environment {
        case .production:
            requestHandler = NetworkRequestHandler()
        case .mock:
            requestHandler = MockRequestHandler()
        default:
            //Default use actual
            requestHandler = NetworkRequestHandler()
            
        }
    }
    
    // MARK: - Functions
    /**
        GET request invoked to Data.gov.sg for retrieving mobile data usage information
        - Parameters:
            - numberOfItems: The number of item to get per request
            - offset: Number of item to skip starting from 0
            - completion: Callback to be executed regardless of success or failure of call but executed before success callback or fail callback is triggered
            - success: Callback to be executed on success block of network call
            - fail: Callback to be executed on the failure block of the network call
     */
    func requestDataUsage(numberOfItems : Int, offset: Int,completion:@escaping ()->Void, success:@escaping (_ result: MobileDataUsageResponse)->Void, fail:@escaping (_ error: Error)->Void){
        let requestParameter = MobileDataRequest(resourceId: RESOURCE_ID, limit: numberOfItems, offset: offset)
        requestHandler.request(url: mobileApiUrl, parameter: requestParameter.parametersRepresentation).validate(statusCode: 200..<300).responseDecodable(of: MobileDataUsageResponse.self) { (data) in
            completion()
            switch data.result {
                case .success(_):
                    if let response = data.value{
                        success(response)
                    }
                    break;
                case .failure(let error):
                    fail(error)
            }
        }
    }
}
