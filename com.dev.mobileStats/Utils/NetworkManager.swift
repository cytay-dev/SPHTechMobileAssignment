//
//  NetworkManager.swift
//  com.dev.mobileStats
//
//  Created by Tay Chee Yang on 2/5/20.
//  Copyright © 2020 cytay. All rights reserved.
//

import Foundation
import Alamofire
class NetworkManager{
    
    
    
    static func request(url: String, parameter: Parameters) -> DataRequest {
        return AF.request(url, parameters: parameter)
    }
}
