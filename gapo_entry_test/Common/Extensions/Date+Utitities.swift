//
//  Date+Utitities.swift
//  gapo_entry_test
//
//  Created by Trung Nguyen on 14/06/2022.
//

import Foundation

extension Date {
    func toDateTime() -> String {
        let df = DateFormatter()
        df.dateFormat = "dd/MM/yyyy, HH:mm"
        return df.string(from: self)
    }
}
