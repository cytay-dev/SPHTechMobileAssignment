//
//  OfflineCacheManager.swift
//  com.dev.mobileStats
//
//  Created by Tay Chee Yang on 2/5/20.
//  Copyright © 2020 cytay. All rights reserved.
//

import Foundation

class OfflineCacheManager{
    private static var sharedOfflineCacheManager: OfflineCacheManager = {
        let mgr = OfflineCacheManager()
        //Do configuration next time
        return mgr
    }()
    
    class func shared() -> OfflineCacheManager {
        return sharedOfflineCacheManager
    }
    
    func saveJSON<T: Codable>(array: T){
        do {
            let data = try JSONEncoder().encode(array)
            if let documentDirectoryUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                let fileUrl = documentDirectoryUrl.appendingPathComponent("data.json")

                try data.write(to: fileUrl)
            }
        } catch {
            print(error)
        }
    }
    
    func readJSON<T: Codable>( _ object: T.Type) -> T? {
         do {
             if let documentDirectoryUrl = FileManager.default
                .urls(for: .documentDirectory, in: .userDomainMask).first {
                  let fileUrl = documentDirectoryUrl.appendingPathComponent("data.json")
                    
                let data = try Data(contentsOf: fileUrl)

                let object = try JSONDecoder().decode(T.self, from: data)
                return object
             }
             return nil
            
        } catch let err{
            print(err)
            return nil
        }
    }
    
}
