//
//  CacheManager.swift
//  Spring Fair
//
//  Created by Gavi Rawson on 1/22/17.
//  Copyright © 2017 Graws Inc. All rights reserved.
//

import Foundation

class CacheManager {
   
    //MARK: Constants
    //***********************************************************************************************
    
    static let shared = CacheManager()

    struct Constants {
        static let jsonCache = "json-cache"
    }
    
    struct Caches {
        static let allEvents = "all-events"
    }
    
    
    //MARK: Variables
    //***********************************************************************************************
    
    enum CacheType {
        case json
    }
    
    
    //MARK: Functions
    //***********************************************************************************************
//    
//    /** Store an object in the cache. */
//    func store(withTitle: String, data: [String: Any]?) -> Bool {
//        guard let data = data else { return false }
//        let jsonData = JSON.dictionary(data)
//        
//        print("printing dats")
//        print(jsonData)
//        
//        let cache = HybridCache(name: Constants.jsonCache)
//        cache.add(withTitle, object: jsonData)
//        return true
//    }
//    
//    func load(withTitle: String) {
//        let cache = HybridCache(name: Constants.jsonCache)
//        cache.object(withTitle) { (json: JSON?) in
//            print(json?.object)
//        }
//    }
    
    
    
    
}
