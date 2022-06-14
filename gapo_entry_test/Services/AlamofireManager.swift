//
//  AlamofireManager.swift
//  gapo_entry_test
//
//  Created by Trung Nguyen on 14/06/2022.
//

import Alamofire
import Moya

struct AlamofireManager {
    
    static let sharedSession: Alamofire.Session = {
        let config = URLSessionConfiguration.default
        config.headers = .default
        config.timeoutIntervalForRequest = 60 // as seconds, you can set your request timeout
        config.timeoutIntervalForResource = 60 // as seconds, you can set your resource timeout
        config.requestCachePolicy = .useProtocolCachePolicy
        
        return Alamofire.Session(configuration: config, startRequestsImmediately: false)
    }()
    
    static let sharedNetworkLoggerPlugin = NetworkLoggerPlugin(configuration: NetworkLoggerPlugin.Configuration(logOptions: .verbose))
    
    #if DEBUG
        static let sharedPlugins: [PluginType] = [AlamofireManager.sharedNetworkLoggerPlugin]
    #else
        static let sharedPlugins: [PluginType] = []
    #endif
}
