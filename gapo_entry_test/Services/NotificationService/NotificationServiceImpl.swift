//
//  NotificationServiceImpl.swift
//  gapo_entry_test
//
//  Created by Trung Nguyen on 14/06/2022.
//

import Foundation
import Moya

extension NotificationService: TargetType {
    var baseURL: URL {
        return URL(string: "https://real-api-go-here.com")!
    }
    
    var path: String {
        return "notification-list"
    }
    
    var method: Moya.Method {
        return .get
    }
    
    var task: Task {
        return .requestPlain
    }
    
    var sampleData: Data {
        return readLocalFile(forName: "noti", ext: "json") ?? Data()
    }
    
    var headers: [String : String]? {
        [
            "Content-Type": "application/json"
        ]
    }
    
}

func readLocalFile(forName name: String, ext: String) -> Data? {
    do {
        if let bundlePath = Bundle.main.path(forResource: name, ofType: ext),
           let data = try String(contentsOfFile: bundlePath).data(using: .utf8) {
            return data
        }
    } catch {
        print(error.localizedDescription)
    }
    return nil
}
