//
//  UIStoryboard+Extension.swift
//  gapo_entry_test
//
//  Created by Trung Nguyen on 14/06/2022.
//

import UIKit

extension UIStoryboard {
    func instantiate<T: UIViewController>() -> T? {
        guard let identifier = String(describing: T.self).components(separatedBy: ".").last else {
            return nil
        }
        
        return instantiateViewController(withIdentifier: identifier) as? T
    }
}
