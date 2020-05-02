//
//  APIClient.swift
//  com.dev.mobileStats
//
//  Created by Tay Chee Yang on 2/5/20.
//  Copyright © 2020 cytay. All rights reserved.
//

import Foundation
import Alamofire

enum APIEnvironment{
    case production
    case mock
}

protocol RequestHandler {
    func request(url: String, parameter: Parameters) -> DataRequest
}

protocol APIClient{
    func requestDataUsage(numberOfItems : Int, offset: Int,completion:@escaping ()->Void, success:@escaping (_ result: MobileDataUsageResponse)->Void, fail:@escaping (_ error: Error)->Void)
}
