//
//  DomainNotification.swift
//  gapo_entry_test
//
//  Created by Trung Nguyen on 14/06/2022.
//

import Foundation

enum NotificationStatus: String, CaseIterable {
    case read, unread
    
    init(from value: String) {
        self = NotificationStatus.allCases.first(where: { $0.rawValue.elementsEqual(value) }) ?? .unread
    }
}

final class DomainNotificationMessage {
    var text: String
    var highlights: [DomainMessageHighlight]
    
    init(text: String, highlights: [DomainMessageHighlight]) {
        self.text = text
        self.highlights = highlights
    }
}

final class DomainMessageHighlight {
    var offset: Int
    var length: Int
    
    init(offset: Int, length: Int) {
        self.offset = offset
        self.length = length
    }
}

final class DomainNotification {
    var id: String
    var imageUrl: String
    var iconUrl: String
    var status: NotificationStatus
    var message: DomainNotificationMessage
    var createdAt: Date
    
    init(id: String, imageUrl: String, iconUrl: String, status: NotificationStatus, message: DomainNotificationMessage, createdAt: Int64) {
        self.id = id
        self.imageUrl = imageUrl
        self.iconUrl = iconUrl
        self.status = status
        self.message = message
        self.createdAt = Date(timeIntervalSince1970: Double(createdAt))
    }
}
