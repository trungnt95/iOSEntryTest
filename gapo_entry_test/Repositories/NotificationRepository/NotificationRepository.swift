//
//  NotificationRepository.swift
//  gapo_entry_test
//
//  Created by Trung Nguyen on 14/06/2022.
//

import Foundation
import RxSwift
import Moya

struct NotificationRepository: Repository {
    typealias T = DomainNotification
    
    private var provider: MoyaProvider<NotificationService> {
        return APIProviders.defaults.notificationProvider
    }
    
    func getList() -> Single<[DomainNotification]> {
        
        return provider.rx.request(.getNotificationList)
            .filterSuccessfulStatusCodes()
            .map(RemoteNotificationList.self)
            .map { remoteNotificationList in
                remoteNotificationList.data
                    .map { remoteNotification -> DomainNotification in
                        let status = NotificationStatus(from: remoteNotification.status)
                        let messageText = remoteNotification.message.text
                        let textHighlights = remoteNotification.message.highlights
                            .map {
                                DomainMessageHighlight(offset: $0.offset, length: $0.length)
                            }
                        let domainMessage = DomainNotificationMessage(text: messageText, highlights: textHighlights)
                        
                        return DomainNotification(id: remoteNotification.id, imageUrl: remoteNotification.imageThumb, iconUrl: remoteNotification.icon, status: status, message: domainMessage, createdAt: remoteNotification.createdAt)
                    }
            }
    }

}
