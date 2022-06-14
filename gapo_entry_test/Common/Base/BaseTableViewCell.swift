//
//  BaseTableViewCell.swift
//  gapo_entry_test
//
//  Created by Trung Nguyen on 14/06/2022.
//

import UIKit
import RxSwift

class BaseTableViewCell: UITableViewCell {

    lazy var disposeBag = DisposeBag()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupUI()
    }

    /// Override this function to setup UI layout
    func setupUI() {
        
    }

}
