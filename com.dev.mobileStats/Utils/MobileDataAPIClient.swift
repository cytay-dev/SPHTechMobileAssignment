//
//  MobileDataAPIClient.swift
//  com.dev.mobileStats
//
//  Created by Tay Chee Yang on 2/5/20.
//  Copyright © 2020 cytay. All rights reserved.
//

import Foundation
import Alamofire
class MobileDataAPIClient : APIClient{
    
    
    private let RESOURCE_ID = "a807b7ab-6cad-4aa6-87d0-e283a7353a0f"
    public static let MOBILE_DATA_API_URL = "https://data.gov.sg/api/action/datastore_search"
    private let mobileApiUrl = MobileDataAPIClient.MOBILE_DATA_API_URL
    private var requestHandler: RequestHandler
    
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
    
    
    class func shared() -> MobileDataAPIClient {
        return sharedAPIClient
    }
    
    class func production() -> MobileDataAPIClient {
        return productionAPIClient
    }
    
    class func mock() -> MobileDataAPIClient {
        return mockAPIClient
    }
    
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
