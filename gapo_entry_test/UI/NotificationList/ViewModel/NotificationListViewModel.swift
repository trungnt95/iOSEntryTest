//
//  NotificationListViewModel.swift
//  gapo_entry_test
//
//  Created by Trung Nguyen on 14/06/2022.
//

import Foundation
import RxSwift
import RxCocoa

final class NotificationListViewModel: BaseViewModel {
    
    private lazy var repository = NotificationRepository()
    
    private let items = BehaviorRelay<[NotificationItem]>(value: [])
    private let searchItems = BehaviorRelay<[NotificationItem]>(value: [])
    
    struct Input {
        let mainListDidTapObservable: Observable<IndexPath>
        let searchTextObservable: Observable<String>
        let searchListDidTapObservable: Observable<IndexPath>
    }
    
    struct Output {
        let notificationItems: Driver<[TableViewCellConfiguration]>
        let mainListItemToBeUpdated: Observable<IndexPath>
        let searchItems: Driver<[TableViewCellConfiguration]>
        let searchListItemToBeUpdated: Observable<IndexPath>
    }
    
    
    func getInput(mainListDidTap: Observable<IndexPath>, searchText: Observable<String>, searchListDidTap: Observable<IndexPath>) -> Input {
        return Input(mainListDidTapObservable: mainListDidTap, searchTextObservable: searchText, searchListDidTapObservable: searchListDidTap)
    }
    
    func transformInput(_ input: Input) -> Output {
        let itemsDriver = items.map { data in
            data.compactMap { $0 as TableViewCellConfiguration }
        }.asDriver(onErrorJustReturn: [])
        
        let mainItemIndexPublisher = PublishSubject<IndexPath>()
        input.mainListDidTapObservable
            .withLatestFrom(items) { indexPath, notifications in
                (indexPath, notifications)
            }
            .subscribe(onNext: {
                let (indexPath, notifications) = $0
                let notification = notifications[indexPath.row]
                if notification.notificationData.status == .unread {
                    notification.notificationData.status = .read
                    mainItemIndexPublisher.onNext(indexPath)
                }
            })
            .disposed(by: disposeBag)
        
        let searchItemsDriver = searchItems.map { data in
            data.compactMap { $0 as TableViewCellConfiguration }
        }.asDriver(onErrorJustReturn: [])
        
        let searchItemIndexPublisher = PublishSubject<IndexPath>()
        input.searchListDidTapObservable
            .withLatestFrom(searchItems) { indexPath, searchNotifications in
                (indexPath, searchNotifications[indexPath.row])
            }
            .withLatestFrom(items) { ($0, $1) }
            .subscribe(onNext: { searchInfoTuple, allNotifications in
                let (searchIndexPath, notification) = searchInfoTuple
                
                guard notification.notificationData.status == .unread else {
                    return
                }
               
                notification.notificationData.status = .read
                
                if let mainIndex = allNotifications.firstIndex(where: { $0.notificationData.id == notification.notificationData.id }) {
                    mainItemIndexPublisher.onNext(IndexPath(row: mainIndex, section: 0))
                }
                
                searchItemIndexPublisher.onNext(searchIndexPath)
            })
            .disposed(by: disposeBag)
        
        input.searchTextObservable
            .distinctUntilChanged()
            .withLatestFrom(items) { textToSearch, notificationItems -> [NotificationItem] in
                guard !textToSearch.isEmpty else {
                    return []
                }
                
                return notificationItems.filter { item in
                    item.notificationData.message.text.contains(textToSearch)
                }
            }
            .bind(to: searchItems)
            .disposed(by: disposeBag)
        
        return Output(notificationItems: itemsDriver,
                      mainListItemToBeUpdated: mainItemIndexPublisher.asObservable(),
                      searchItems: searchItemsDriver,
                      searchListItemToBeUpdated: searchItemIndexPublisher.asObservable())
    }
    
    func fetchNotificationList() -> Completable {
        return Completable.create { [unowned self] observer in
            self.repository.getList().subscribe(onSuccess: { notificationList in
                let items = notificationList.map { NotificationItem(data: $0) }
                self.items.accept(items)
                observer(.completed)
            }, onFailure: { error in
                observer(.error(error))
            })
        }
    }
    
}
