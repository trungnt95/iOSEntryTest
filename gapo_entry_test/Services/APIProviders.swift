//
//  APIProviders.swift
//  gapo_entry_test
//
//  Created by Trung Nguyen on 14/06/2022.
//

import Foundation
import Moya
import Alamofire

final class APIProviders {
    
    private struct shared {
        static let instance = APIProviders()
    }
    
    static var defaults: APIProviders {
        return shared.instance
    }
    
    private init() {}
    
    private(set) lazy var notificationProvider = MoyaProvider<NotificationService>(
        stubClosure: MoyaProvider<NotificationService>.delayedStub(1),
        session: AlamofireManager.sharedSession,
        plugins: AlamofireManager.sharedPlugins)
}
