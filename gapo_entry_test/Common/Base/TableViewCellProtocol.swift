//
//  TableViewCellProtocol.swift
//  gapo_entry_test
//
//  Created by Trung Nguyen on 14/06/2022.
//

import UIKit

protocol ReusableCell: AnyObject {
    static var cellIdentifier: String { get }
    static var nib: UINib { get }
}

extension ReusableCell {
    static var cellIdentifier: String {
        return String(describing: self).components(separatedBy: ".").last ?? ""
    }
}

protocol TableViewCellConfiguration {
    var reusable: ReusableCell.Type { get }
    func configCell(_ cell: UITableViewCell)
}
