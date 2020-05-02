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

class MockRequestHandler: RequestHandler{
    private static var sessionManager: Session = {
      let configuration = URLSessionConfiguration.af.default
      configuration.protocolClasses = [MockingURLProtocol.self] + (configuration.protocolClasses ?? [])
      let sessionManager = Session(configuration: configuration)
        return sessionManager
    }()
    
    static func request(url: String, parameter: Parameters) -> DataRequest {
        return sessionManager.request(url,parameters: parameter)
    }
}
