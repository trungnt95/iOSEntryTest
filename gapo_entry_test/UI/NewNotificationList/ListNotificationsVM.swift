//
//  ListNotificationsVM.swift
//  gapo_entry_test
//
//  Created by Trung Nguyen on 04/07/2022.
//

import UIKit
import DTMvvm
import RxCocoa
import RxSwift

final class ListNotificationsVM: ListViewModel<Model, NewNotificationItemCellVM> {
    
    func updateList(_ list: [NewNotificationItemCellVM]) {
        itemsSource.reset([list])
    }
    
    func updateData(with notification: DomainNotification) {
        guard let cvmIndex = itemsSource.firstIndex(where: { cvm in
            cvm.model?.id == notification.id
        }, at: 0) else {
            return
        }
        
        let cvm = itemsSource.element(atSection: 0, row: cvmIndex) as? NewNotificationItemCellVM
        cvm?.updateState()
    }
}

final class NewNotificationListVM: ViewModel<Model> {
    
    private lazy var repository = NotificationRepository()
    
    private let items = BehaviorRelay<[DomainNotification]>(value: [])
    
    private(set) var mainListVM = ListNotificationsVM(model: nil)
    private(set) var searchListVM = ListNotificationsVM(model: nil)
    
    let searchText = BehaviorRelay<String>(value: "")
    
    override func react() {
        super.react()
        
        let sharedItems = items.share(replay: 1)
        
        Observable.combineLatest(sharedItems, searchText.asObservable())
            .map { notifications, textToSearch -> [NewNotificationItemCellVM] in
                guard !textToSearch.isEmpty else {
                    return []
                }
                return notifications.filter { notification in notification.message.text.contains(textToSearch) }
                    .map { NewNotificationItemCellVM(model: $0) }
            }
            .subscribe(onNext: { [weak self] in
                self?.searchListVM.updateList($0)
            })
            => disposeBag
        
        
        sharedItems
            .map { listItems in listItems.map { NewNotificationItemCellVM(model: $0) } }
            .subscribe(onNext: { [weak self] in
                self?.mainListVM.updateList($0)
            })
            => disposeBag
        
        Observable.merge(mainListVM.rxSelectedItem.asObservable(), searchListVM.rxSelectedItem.asObservable())
            .compactMap { $0?.model }
            .subscribe(onNext: { [weak self] notification in
                if notification.status == .unread {
                    notification.status = .read
                    self?.mainListVM.updateData(with: notification)
                    self?.searchListVM.updateData(with: notification)
                }
            })
            => disposeBag
        
        fetchNotificationList()
            .observe(on: MainScheduler.instance)
            .subscribe(onCompleted: {
                
            }, onError: { _ in
                
            })
            => disposeBag
        
    }
    
    private func fetchNotificationList() -> Completable {
        return Completable.create { [unowned self] observer in
            self.repository.getList().subscribe(onSuccess: { notifications in
                self.items.accept(notifications)
                observer(.completed)
            }, onFailure: { error in
                observer(.error(error))
            })
        }
    }
}
