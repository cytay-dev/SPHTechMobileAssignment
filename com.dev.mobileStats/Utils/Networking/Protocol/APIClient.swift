//
//  APIClient.swift
//  com.dev.mobileStats
//
//  Created by Tay Chee Yang on 2/5/20.
//  Copyright © 2020 cytay. All rights reserved.
//

import Foundation
import Alamofire

// MARK: - Enums
/**
 Enum for use by API Client to determine if API Client is for actual service or mock service
 */
enum APIEnvironment{
    case production
    case mock
}

// MARK: - Protocols
/**
 Protocol to be implemented by all request handler for calling to outside network service
 */
protocol RequestHandler {
    func request(url: String, parameter: Parameters) -> DataRequest
}

/**
 Protocol to be implemented by all API Client to manage netwrok request and response
 */
protocol APIClient{
    func requestDataUsage(numberOfItems : Int, offset: Int,completion:@escaping ()->Void, success:@escaping (_ result: MobileDataUsageResponse)->Void, fail:@escaping (_ error: Error)->Void)
}
