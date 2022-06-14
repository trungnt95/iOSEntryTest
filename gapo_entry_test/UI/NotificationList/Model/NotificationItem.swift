//
//  NotificationItem.swift
//  gapo_entry_test
//
//  Created by Trung Nguyen on 14/06/2022.
//

import UIKit

final class NotificationItem {
    var notificationData: DomainNotification
    
    init(data: DomainNotification) {
        self.notificationData = data
    }
}

extension NotificationItem: TableViewCellConfiguration {
    var reusable: ReusableCell.Type {
        return NotificationItemCell.self
    }
    
    func configCell(_ cell: UITableViewCell) {
        if let inCell = cell as? NotificationItemCell {
            inCell.bindItem(self)
        }
    }
}
