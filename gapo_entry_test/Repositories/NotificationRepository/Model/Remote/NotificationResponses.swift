//
//  NotificationResponses.swift
//  gapo_entry_test
//
//  Created by Trung Nguyen on 14/06/2022.
//

import Foundation

struct RemoteNotificationList: Decodable {
    let data: [RemoteNotification]
}

struct RemoteNotification: Decodable {
    let id: String
    let status: String
    let image: String
    let imageThumb: String
    let icon: String
    let message: NotificationMessage
    let createdAt: Int64
}

struct NotificationMessage: Decodable {
    let text: String
    let highlights: [MessageHighlight]
}

struct MessageHighlight: Decodable {
    let offset: Int
    let length: Int
}
