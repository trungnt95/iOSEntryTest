//
//  UITableViewCell+Reusable.swift
//  gapo_entry_test
//
//  Created by Trung Nguyen on 14/06/2022.
//

import UIKit

extension UITableViewCell: ReusableCell {
    static var nib: UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
}
