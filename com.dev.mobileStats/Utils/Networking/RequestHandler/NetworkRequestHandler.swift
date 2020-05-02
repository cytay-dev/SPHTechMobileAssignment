//
//  NetworkManager.swift
//  com.dev.mobileStats
//
//  Created by Tay Chee Yang on 2/5/20.
//  Copyright © 2020 cytay. All rights reserved.
//

import Foundation
import Alamofire

/**
 Network request handler that make actual service request to API servers using Alamofire
 */
class NetworkRequestHandler : RequestHandler{
    // MARK: - Functions
    /**
     Make request ot API server using given url and parameters
     - Parameters:
        -   url: Url of the service
        - parameter: Parameters to be included in the query string of the url
     */
    func request(url: String, parameter: Parameters) -> DataRequest {
        return AF.request(url, parameters: parameter)
    }
}
