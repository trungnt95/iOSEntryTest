//
//  DataEnums.swift
//  gapo_entry_test
//
//  Created by Trung Nguyen on 14/06/2022.
//

import UIKit

enum AllBoards: String {
    case main = "Main"
    
    var storyboard: UIStoryboard {
        return UIStoryboard(name: self.rawValue, bundle: nil)
    }
}
