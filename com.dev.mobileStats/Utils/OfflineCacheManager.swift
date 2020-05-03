//
//  OfflineCacheManager.swift
//  com.dev.mobileStats
//
//  Created by Tay Chee Yang on 2/5/20.
//  Copyright © 2020 cytay. All rights reserved.
//

import Foundation

/**
 Cache manager for offline content usage
 */
class OfflineCacheManager{
    // MARK: - Variables
    private static let ACTUAL_FILE_NAME = "data.json"
    private static let MOCK_FILE_NAME = "data-mock.json"
    private var fileName = "data.json"
    private static var sharedOfflineCacheManager: OfflineCacheManager = {
        //Handle in case is triggered by UI Test cases
        #if DEBUG
        if ProcessInfo.processInfo.arguments.contains("UI-TESTING") {
            return OfflineCacheManager(fileName: MOCK_FILE_NAME)
        }
        #endif
        
        let mgr = OfflineCacheManager(fileName: ACTUAL_FILE_NAME)
        //Do configuration next time
        return mgr
    }()
    
    private static var mockOfflineCacheManager: OfflineCacheManager = {
        let mgr = OfflineCacheManager(fileName: MOCK_FILE_NAME)
        //Do configuration next time
        return mgr
    }()
    
    init(fileName: String){
        self.fileName = fileName
    }
    
    // MARK: - Functions
    ///Return single instance for accessing cache functions
    class func shared() -> OfflineCacheManager {
        return sharedOfflineCacheManager
    }
    
    ///Return single instance for accessing cache functions in unit testing
    class func mock() -> OfflineCacheManager {
        return mockOfflineCacheManager
    }
    
    ///Save response to be used in cache situation mainly for during when network is unavaiable
    func saveJSON<T: Codable>(array: T) throws{
        let data = try JSONEncoder().encode(array)
        if let documentDirectoryUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileUrl = documentDirectoryUrl.appendingPathComponent(fileName)

            try data.write(to: fileUrl)
        }
    }
    
    ///Read cached response stored in json format for offline cache usage
    func readJSON<T: Codable>( _ object: T.Type) throws -> T?{
          if let documentDirectoryUrl = FileManager.default
                        .urls(for: .documentDirectory, in: .userDomainMask).first {
                          let fileUrl = documentDirectoryUrl.appendingPathComponent(fileName)
                            
                        let data = try Data(contentsOf: fileUrl)

                        let object = try JSONDecoder().decode(T.self, from: data)
                        return object
                     }
                     return nil
    }
    
}
