//
//  MobileDataAPIClient.swift
//  com.dev.mobileStats
//
//  Created by Tay Chee Yang on 2/5/20.
//  Copyright © 2020 cytay. All rights reserved.
//

import Foundation
import Alamofire
class MobileDataAPIClient{
    
    private static let RESOURCE_ID = "a807b7ab-6cad-4aa6-87d0-e283a7353a0f"
    private static let MOBILE_DATA_API_URL = "https://data.gov.sg/api/action/datastore_search"
    
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
    
    static func requestDataUsage(numberOfItems : Int, offset: Int,completion:@escaping ()->Void, success:@escaping (_ result: MobileDataUsageResponse)->Void, fail:@escaping (_ error: Error)->Void){
        let requestParameter = MobileDataRequest(resourceId: RESOURCE_ID, limit: numberOfItems, offset: offset)
        NetworkManager.request(url: MOBILE_DATA_API_URL, parameter: requestParameter.parametersRepresentation).responseDecodable(of: MobileDataUsageResponse.self) { (data) in
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
