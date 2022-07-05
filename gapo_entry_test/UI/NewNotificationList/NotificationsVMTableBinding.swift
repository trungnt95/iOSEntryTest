//
//  NotificationsVMTableBinding.swift
//  gapo_entry_test
//
//  Created by Trung Nguyen on 04/07/2022.
//

import UIKit
import DTMvvm

final class NotificationsVMTableBinding: TableBindingHelper<ListNotificationsVM> {
    override func initialize() {
        super.initialize()
        tableView.register(NewNotificationItemCell.nib, forCellReuseIdentifier: NewNotificationItemCell.identifier)
    }
    
    override func cellIdentifier(_ cellViewModel: TableBindingHelper<ListNotificationsVM>.CVM) -> String {
        return NewNotificationItemCell.identifier
    }
}
